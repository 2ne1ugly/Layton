defmodule Layton.System.LobbyServer do
  @moduledoc """
  Server that keeps track on list of lobbies (including on-going ones.)
  """
  use GenServer
  alias __MODULE__

  defstruct lobby_map: %{}

  #
  # Client Functions
  #

  def create_lobby(player_info, lobby) do
    GenServer.call(__MODULE__, {:create_lobby, player_info, lobby})
  end

  def join_lobby(player_info, lobby_uuid) do
    GenServer.call(__MODULE__, {:join_lobby, player_info, lobby_uuid})
  end

  def leave_lobby(player_info, lobby_uuid) do
    GenServer.call(__MODULE__, {:leave_lobby, player_info, lobby_uuid})
  end

  def update_lobby_state(lobby_uuid, lobby_state) do
    GenServer.cast(__MODULE__, {:leave_lobby, lobby_uuid, lobby_state})
  end

  def get_lobby_stream(lobby_uuid) do
    GenServer.call(__MODULE__, {:get_lobby_stream, lobby_uuid})
  end

  def find_lobbies() do
    GenServer.call(__MODULE__, :find_lobbies)
  end

  #
  # Bindings
  #
  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    {:ok, %LobbyServer{}}
  end

  @impl true
  def handle_call({:create_lobby, player_info, lobby}, _from, state) do
    lobby = %{
      lobby
      | lobby_uuid: Ecto.UUID.bingenerate(),
        host_player_username: player_info.username,
        players: %{player_info.username => player_info}
    }

    lobby = %{lobby | lobby_stream: Layton.Object.LobbyStream.start([lobby])}
    state = put_in(state.lobby_map[lobby.lobby_uuid], lobby)
    Layton.System.PlayerServer.update_current_lobby(player_info.username, lobby.lobby_uuid)
    {:reply, lobby.lobby_uuid, state}
  end

  @impl true
  def handle_call(:find_lobbies, _from, state) do
    {:reply, Map.values(state.lobby_map), state}
  end

  @impl true
  def handle_call({:join_lobby, player_info, lobby_uuid}, _from, state) do
    case Map.fetch(state.lobby_map, lobby_uuid) do
      :error ->
        {:reply, :error, state}

      {:ok, lobby} ->
        if map_size(lobby.players) >= lobby.max_players do
          {:reply, :error, state}
        else
          lobby = put_in(lobby.players[player_info.username], player_info)
          Layton.Object.LobbyStream.notify_join_lobby(lobby.stream, player_info)
          state = put_in(state.lobby_map[lobby_uuid], lobby)
          {:reply, :ok, state}
        end
    end
  end

  @impl true
  def handle_call({:leave_lobby, player_info, lobby_uuid}, _from, state) do
    case Map.get(state.lobby_map, lobby_uuid) do
      nil ->
        {:reply, :error, state}

      lobby ->
        lobby = pop_in(lobby.players[player_info.username], player_info)
        Layton.Object.LobbyStream.notify_leave_lobby(lobby.stream, player_info)

        state =
          if map_size(lobby.players) == 0 do
            pop_in(state.lobby_map[lobby_uuid])
          else
            put_in(state.lobby_map[lobby_uuid], lobby)
          end

        {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call({:get_lobby_stream, lobby_uuid}, _from, state) do
    case Map.get(state.lobby_map, lobby_uuid) do
      nil -> {:reply, :error, state}
      lobby -> {:reply, lobby.lobby_stream, state}
    end
  end

  @impl true
  def handle_cast({:leave_lobby, lobby_uuid, lobby_state}, state) do
    state = put_in(state.lobby_map[lobby_uuid].lobby_state, lobby_state)
    {:noreply, state}
  end
end
