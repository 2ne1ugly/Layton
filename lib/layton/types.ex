defmodule Layton.Types.Lobby do
  defstruct lobby_name: "", lobby_uuid: "", map_name: "", host_player: "", players: [], max_players: 10, lobby_state: :LS_WAITING_FOR_MATCH
end

defmodule Layton.Types.Player do
  defstruct username: "", auth_token: "", current_lobby: ""
end
