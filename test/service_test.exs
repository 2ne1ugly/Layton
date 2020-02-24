defmodule Service.Test do
  use Layton.Test.RepoCase

  alias Lgrpc.LaytonClient.Stub
  test "LaytonClientService" do
    {:ok, channel} = GRPC.Stub.connect("localhost:50051")
    username = "test"

    #login failure test
    request = Lgrpc.LoginRequest.new(username: username)
    {:ok, response} = Stub.login(channel, request)
    expected_response = Lgrpc.LoginResponse.new(result_code: :RC_FAIL)
    assert Map.equal?(response, expected_response)

    #create account test
    request = Lgrpc.CreateAccountRequest.new(username: username)
    {:ok, response} = Stub.create_account(channel, request)
    expected_response = Lgrpc.Result.new(result_code: :RC_SUCCESS)
    assert Map.equal?(response, expected_response)

    #create duplicate failure test
    request = Lgrpc.CreateAccountRequest.new(username: username)
    {:ok, response} = Stub.create_account(channel, request)
    expected_response = Lgrpc.Result.new(result_code: :RC_FAIL)
    assert Map.equal?(response, expected_response)

    #login success test
    request = Lgrpc.LoginRequest.new(username: username)
    {:ok, response} = Stub.login(channel, request)
    expected_response = Lgrpc.LoginResponse.new(
      result_code: :RC_SUCCESS,
      auth_token: response.auth_token
    )
    assert Map.equal?(response, expected_response)

    auth_token = response.auth_token

    #find_lobbies no header test
    request = Lgrpc.FindLobbiesRequest.new()
    {:ok, response} = Stub.find_lobbies(channel, request)
    expected_response = Lgrpc.FindLobbiesResponse.new(result_code: :RC_ERROR)
    assert Map.equal?(response, expected_response)

    #find_lobbies with header test
    request = Lgrpc.FindLobbiesRequest.new()
    metadata = %{
      "custom-username" => username,
      "custom-auth-token-bin" => auth_token
    }
    {:ok, response} = Stub.find_lobbies(channel, request, [metadata: metadata])
    expected_response = Lgrpc.FindLobbiesResponse.new(result_code: :RC_SUCCESS)
    assert Map.equal?(response, expected_response)

    #create_lobby test
    request = Lgrpc.CreateLobbyRequest.new(
      lobby_name: "SAVEME",
      map_name: "air_station_3",
      max_players: 10
    )
    metadata = %{
      "custom-username" => username,
      "custom-auth-token-bin" => auth_token
    }
    {:ok, response} = Stub.create_lobby(channel, request, [metadata: metadata])
    expected_response = Lgrpc.CreateLobbyResponse.new(
      result_code: :RC_SUCCESS,
      lobby_uuid: response.lobby_uuid
    )
    assert Map.equal?(response, expected_response)

    #lobby_stream unknown failure test
    metadata = %{
      "custom-username" => username,
      "custom-auth-token-bin" => auth_token,
      "custom-lobby-uuid-bin" => ""
    }
    stream = Stub.lobby_stream(channel, [metadata: metadata])
    {:ok, resp_enum} = GRPC.Stub.recv(stream)
    [{:ok, first_message}] = Enum.to_list(Stream.take(resp_enum, 1))
    expected_first_message = Lgrpc.LobbyStreamServer.new(
      message: {:init, Lgrpc.LobbyStreamInitialize.new(result_code: :RC_ERROR)}
    )
    assert Map.equal?(first_message, expected_first_message)

    lobby_uuid = response.lobby_uuid

    #lobby_stream test
    metadata = %{
      "custom-username" => username,
      "custom-auth-token-bin" => auth_token,
      "custom-lobby-uuid-bin" => lobby_uuid
    }
    stream = Stub.lobby_stream(channel, [metadata: metadata])
    {:ok, resp_enum} = GRPC.Stub.recv(stream)
    [{:ok, first_message}] = Enum.to_list(Stream.take(resp_enum, 1))
    {:init, %{players: players}} = first_message.message
    expected_first_message = Lgrpc.LobbyStreamServer.new(%{
      message: {:init, %Lgrpc.LobbyStreamInitialize{
        result_code: :RC_SUCCESS,
        lobby_name: "SAVEME",
        lobby_state: :LS_WAITING_FOR_MATCH,
        map_name: "air_station_3",
        max_players: 10,
        players: players
    }}})
    assert Map.equal?(first_message, expected_first_message)

  end
end
