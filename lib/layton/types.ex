defmodule Layton.Types.Lobby do
  defstruct lobby_name: "",
            lobby_uuid: "",
            lobby_stream: nil,
            map_name: "",
            host_player_username: "",
            max_players: 10,
            num_players: 0,
            lobby_state: :LS_PENDING
end

defmodule Layton.Types.Player.PlayerInfo do
  defstruct username: ""
end

defmodule Layton.Types.Player do
  alias __MODULE__
  defstruct player_info: %Player.PlayerInfo{}, auth_token: "", current_lobby: "", lobby_uuid: ""
end

defmodule Layton.Types.PlayerStream do
  defstruct stream: nil, player_info: nil
end
