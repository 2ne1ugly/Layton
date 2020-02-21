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
      state =
        put_in(
          state.players[player_info.username],
          %Layton.Types.PlayerStream{stream: stream, player_info: player_info}
        )

      if state.host_player_username == player_info.username do
        state = put_in(state.lobby_state, :LS_WAITING_FOR_MATCH)
        Layton.System.LobbyServer.activate_lobby(state)
      end

      Layton.System.LobbyServer.update_lobby(state)
      {:reply, :ok, state}
    end
  end

  @impl true
  def handle_cast({:leave_lobby_stream, player_info}, state) do
    case pop_in(state.players, player_info.username) do
      {nil, state} ->
        Logger.error("Trying to leave lobby that doesn't exist {player_info.username}")
        {:noreply, state}

      {_, state} ->
        if map_size(state.players) == 0 do
          Layton.System.LobbyServer.destroy_lobby(state)
        else
          Layton.System.LobbyServer.update_lobby(state)
        end
        {:noreply, state}
    end
  end
end
