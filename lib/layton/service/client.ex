defmodule Layton.Client.Service do
  use GRPC.Server, service: Lgrpc.LaytonClient.Service

  ##
  ##  identity
  ##
  def create_account(request, _stream) do
    changeset = Layton.Schema.Account.changeset(request)

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
        {_, auth_token} = Layton.System.PlayerServer.login_player(player)
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
        uuid = Layton.System.LobbyServer.create_lobby(player.player_info, lobby)
        Lgrpc.CreateLobbyResponse.new(result_code: :RC_SUCCESS, lobby_uuid: uuid)
    end
  end

  def stream_lobby(req_enum, stream) do
    Enum.reduce(req_enum, fn elem, elems ->
      IO.inspect(elem)
      end)
  end

  def find_lobbies(_request, _stream) do
    lobbies =
      Enum.map(
        Layton.System.LobbyServer.find_lobbies(),
        &struct(Lgrpc.LobbyInfo, Map.from_struct(&1))
      )

    Lgrpc.FindLobbiesResponse.new(result_code: :RC_SUCCESS, lobbies: lobbies)
  end
end
