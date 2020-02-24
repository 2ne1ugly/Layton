# defmodule Layton.Test do
#   use ExUnit.Case
#   doctest Layton

#   alias Layton.System.LobbyServer
#   test "LobbyServer" do
#     #Check creation
#     player_info = %Layton.Types.Player.PlayerInfo{username: "TEST"}
#     lobby = %Layton.Types.Lobby{lobby_name: "HMM"}
#     uuid = LobbyServer.create_lobby(player_info, lobby)
#     assert is_binary(uuid)

#     #Check stream
#     {:ok, _} = LobbyServer.get_lobby_stream(uuid)

#     #Check destroy
#     LobbyServer.destroy_lobby(uuid)
#     assert :error == LobbyServer.get_lobby_stream(uuid)
#   end

#   alias Layton.System.PlayerServer
#   test "PlayerServer" do
#     #check login
#     player_info = %Layton.Types.Player.PlayerInfo{username: "TEST"}
#     player = %Layton.Types.Player{player_info: player_info}
#     {result, first_auth_token} = PlayerServer.login_player(player)
#     assert result == :ok
#     {result, auth_token} = PlayerServer.login_player(player)
#     assert result == :already_logged_in
#     assert first_auth_token != auth_token

#   end
# end
