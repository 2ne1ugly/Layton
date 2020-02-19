defmodule Layton.Object.LobbyStream do
  @moduledoc """
  A Lobby as entity; manages itself and communicates with lobby server
  """
  use GenServer
  alias __MODULE__

  defstruct lobby_name: "",
            lobby_uuid: "",
            map_name: "",
            host_player_username: "",
            players: %{},
            player_streams: %{},
            max_players: 10,
            lobby_state: :LS_PENDING

  def notify_join_lobby(pid, player_info) do
    GenServer.cast(pid, {:notify_join_lobby, player_info})
  end

  def notify_leave_lobby(pid, player_info) do
    GenServer.cast(pid, {:notify_leave_lobby, player_info})
  end

  def join_lobby_stream(pid, username, stream) do
    # Theoretically, this should always work
    GenServer.call(pid, {:join_lobby_stream, username, stream})
  end

  def leave_lobby_stream(pid, username) do
    # Theoretically, this should always work
    GenServer.call(pid, {:leave_lobby_stream, username})
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
  def handle_call({:join_lobby_stream, username, stream}, _from, state) do
    if Map.has_key?(state.players, username) do
      state = put_in(state.player_streams[username], %Layton.Types.PlayerStream{stream: stream})
      state =
        if state.host_player_username == username do
          put_in(state.lobby_state, :LS_WAITING_FOR_MATCH)
        end

      {:reply, :ok, state}
    else
      {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:leave_lobby_stream, username}, _from, state) do
    state = pop_in(state.player_streams, username)
    {:reply, :ok, state}
  end

  @impl true
  def handle_cast({:notify_join_lobby, player_info}, state) do
    state = put_in(state.players[player_info.username], player_info)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:notify_leave_lobby, player_info}, state) do
    state = pop_in(state.players, player_info.username)

    cond do
      map_size(state.players) == 0 ->
        {:stop, :normal, state}

      state.host_player_username == player_info.username ->
        {new_host, _} = Enum.random(state.players)
        {:noreply, put_in(state.host_player_username, new_host)}

      true ->
        {:noreply, state}
    end
  end
end
