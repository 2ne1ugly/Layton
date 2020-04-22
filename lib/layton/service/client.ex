defmodule Layton.Client.Service do
  use GRPC.Server, service: Lgrpc.LaytonClient.Service
  require Logger

  alias Layton.System.PlayerServer
  alias Layton.System.LobbyServer
  alias Layton.Object.LobbyStream

  ##
  ##  identity
  ##
  def create_account(request, _stream) do
    account = struct(Layton.Schema.Account, Map.from_struct(request))

    changeset = Layton.Schema.Account.changeset(account)

    case Layton.Repo.insert(changeset) do
      {:ok, _} -> Lgrpc.Result.new(result_code: :RC_SUCCESS)
      {:error, _} -> Lgrpc.Result.new(result_code: :RC_FAIL)
    end
  end

  def login(request, _stream) do
    # Check If it's inside the database and return true/false
    case Layton.Repo.get_by(Layton.Schema.Account, Map.from_struct(request)) do
      nil ->
        Lgrpc.LoginResponse.new(result_code: :RC_FAIL)

      account ->
        player_info = struct(Layton.Types.Player.PlayerInfo, Map.from_struct(account))
        player = %Layton.Types.Player{player_info: player_info}
        {_, auth_token} = PlayerServer.login_player(player)
        Lgrpc.LoginResponse.new(result_code: :RC_SUCCESS, auth_token: auth_token)
    end
  end

  ##
  ##  Lobby
  ##

  def create_lobby(request, stream) do
    case Layton.Utils.fetch_online_player_from_stream(stream) do
      :error ->
        Lgrpc.CreateLobbyResponse.new(result_code: :RC_ERROR)

      {:ok, player} ->
        lobby = struct(Layton.Types.Lobby, Map.from_struct(request))
        uuid = LobbyServer.create_lobby(player.player_info, lobby)
        Lgrpc.CreateLobbyResponse.new(result_code: :RC_SUCCESS, lobby_uuid: uuid)
    end
  end

  def lobby_stream(req_enum, stream) do
    headers = GRPC.Stream.get_headers(stream)

    with {:ok, player} <- Layton.Utils.fetch_online_player_from_stream(stream),
         {:ok, lobby_stream} <- LobbyServer.get_lobby_stream(headers["custom-lobby-uuid"]),
         {:ok, lobby} <- LobbyStream.join_lobby_stream(lobby_stream, player.player_info, stream) do
      send_lobby_stream_init(lobby, stream)
      do_lobby_stream(req_enum, lobby_stream, player)
      Layton.Object.LobbyStream.leave_lobby_stream(lobby_stream, player.player_info)
    else
      _ ->
        init = Lgrpc.LobbyStreamInitialize.new(result_code: :RC_ERROR)
        GRPC.Server.send_reply(stream, Lgrpc.LobbyStreamServer.new(message: {:init, init}))
    end
  end

  def find_lobbies(_request, stream) do
    case Layton.Utils.fetch_online_player_from_stream(stream) do
      {:ok, _} ->
        lobbies =
          LobbyServer.find_lobbies()
          |> Enum.map(&struct(Lgrpc.LobbyInfo, Map.from_struct(&1)))

        Lgrpc.FindLobbiesResponse.new(result_code: :RC_SUCCESS, lobbies: lobbies)

      :error ->
        Lgrpc.FindLobbiesResponse.new(result_code: :RC_ERROR)
    end
  end

  defp send_lobby_stream_init(lobby, stream) do
    players =
      Map.values(lobby.player_streams)
      |> Enum.map(&Lgrpc.PlayerInfo.new(Map.from_struct(&1.player_info)))

    init =
      Lgrpc.LobbyStreamInitialize.new(result_code: :RC_SUCCESS, players: players)
      |> struct(Map.from_struct(lobby))

    GRPC.Server.send_reply(stream, Lgrpc.LobbyStreamServer.new(message: {:init, init}))
  end

  defp do_lobby_stream(req_enum, lobby_stream, player) do
    Enum.each(req_enum, fn msg ->
      case msg.message do
        {:send_chat_message, message} ->
          Layton.Object.LobbyStream.send_chat_message(
            lobby_stream,
            player.player_info,
            message.message
          )

        {:action, action} ->
          case action do
            :LSA_LEAVE_LOBBY -> IO.inspect("Left")
            _ -> Logger.error("Unknown Action", action)
          end

        {_, arbitary} ->
          IO.inspect(arbitary)
      end
    end)
  end
end
