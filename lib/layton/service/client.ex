defmodule Layton.Client.Service do
  use GRPC.Server, service: Lgrpc.LaytonClient.Service

  ##
  ##  IDENTITY
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
      nil -> Lgrpc.LoginResponse.new(result_code: :RC_FAIL)
      account ->
        player = struct(Layton.Types.Player, Map.from_struct(account))
        {_, auth_token} = Layton.System.PlayerServer.login_player(player)
        Lgrpc.LoginResponse.new(result_code: :RC_SUCCESS, auth_token: auth_token)
    end
  end

  ##
  ##  Lobby
  ##

  def create_lobby(request, stream) do
    headers = GRPC.Stream.get_headers(stream)
    case Layton.System.PlayerServer.verify_auth_token(headers["custom-username"], headers["custom-auth-token-bin"]) do
      :error -> Lgrpc.CreateLobbyResponse.new(result_code: :RC_ERROR)
      {:ok, player} ->
        lobby = struct(Layton.Types.Lobby, Map.from_struct(request))
        uuid = Layton.System.LobbyServer.create_lobby(player, lobby)
        Lgrpc.CreateLobbyResponse.new(result_code: :RC_SUCCESS, lobby_uuid: uuid)
    end
  end

  def join_lobby(_request, _stream) do
    # case Layton.Lgrpc.Server.Session.join_lobby() do

    # end
    Lgrpc.Result.new(result_code: :RC_ERROR)  # Deduct user from stream
  end

  def subscribe_lobby_stream(_request, _stream) do
  end

  def find_lobbies(_request, _stream) do
    lobbies = Enum.map(Layton.System.LobbyServer.find_lobbies(),
      fn lobby ->
        %{lobby | __struct__: Lgrpc.LobbyInfo}
      end)
    Lgrpc.FindLobbiesResponse.new(result_code: :RC_SUCCESS, lobbies: lobbies)
  end
end
