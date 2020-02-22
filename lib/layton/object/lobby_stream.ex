defmodule Layton.Object.LobbyStream do
  @moduledoc """
  A Lobby as entity; manages itself and communicates with lobby server
  """
  use GenServer
  alias __MODULE__
  require Logger

  defstruct lobby_name: "",
            lobby_uuid: "",
            map_name: "",
            host_player_username: "",
            players: %{},
            max_players: 10,
            lobby_state: :LS_PENDING

  def join_lobby_stream(pid, player_info, stream) do
    GenServer.call(pid, {:join_lobby_stream, player_info, stream})
  end

  def leave_lobby_stream(pid, player_info) do
    GenServer.cast(pid, {:leave_lobby_stream, player_info})
  end

  #
  # Bindings
  #
  def start([lobby]) do
    GenServer.start(__MODULE__, [lobby])
  end

  @impl true
  def init([lobby]) do
    {:ok, struct(LobbyStream, Map.from_struct(lobby))}
  end

  @impl true
  def handle_call({:join_lobby_stream, player_info, stream}, _from, state) do
    if map_size(state.players) >= state.max_players do
      {:reply, :error, state}
    else
      username = player_info.username
      state =
        put_in(
          state.players[username],
          %Layton.Types.PlayerStream{stream: stream, player_info: player_info}
        )
      state =
        case state.host_player_username do
          ^username -> put_in(state.lobby_state, :LS_WAITING_FOR_MATCH)
          _ -> state
        end
      Layton.System.LobbyServer.update_lobby(state)
      {:reply, {:ok, state}, state}
    end
  end

  @impl true
  def handle_cast({:leave_lobby_stream, player_info}, state) do
    {elem, state} = pop_in(state.players, player_info.username)
    case elem do
      nil -> Logger.error("Trying to leave lobby that doesn't exist {player_info.username}")
      %{players: players} when map_size(players) == 0 -> Layton.System.LobbyServer.destroy_lobby(state.lobby_uuid)
      _ -> Layton.System.LobbyServer.update_lobby(state)
    end
    {:noreply, state}
  end
end
