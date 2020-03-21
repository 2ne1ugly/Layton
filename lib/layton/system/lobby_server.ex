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

  def update_lobby(lobby) do
    GenServer.cast(__MODULE__, {:update_lobby, lobby})
  end

  def destroy_lobby(lobby_uuid) do
    GenServer.cast(__MODULE__, {:destroy_lobby, lobby_uuid})
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
      | lobby_uuid: Ecto.UUID.generate(),
        host_player_username: player_info.username
    }
    {:ok, stream} = Layton.Object.LobbyStream.start([lobby])
    lobby = %{lobby | lobby_stream: stream}
    state = put_in(state.lobby_map[lobby.lobby_uuid], lobby)
    {:reply, Ecto.UUID.load(lobby.lobby_uuid) , state}
  end

  @impl true
  def handle_call(:find_lobbies, _from, state) do
    {:reply, Map.values(state.lobby_map), state}
  end

  @impl true
  def handle_call({:get_lobby_stream, lobby_uuid}, _from, state) do
    case Map.get(state.lobby_map, lobby_uuid) do
      nil -> {:reply, :error, state}
      lobby -> {:reply, {:ok, lobby.lobby_stream}, state}
    end
  end

  @impl true
  def handle_cast({:update_lobby, lobby}, state) do
    new_lobby = struct(state.lobby_map[lobby.lobby_uuid], Map.from_struct(lobby))
    new_lobby = put_in(new_lobby.num_players, map_size(lobby.player_streams))
    state = put_in(state.lobby_map[lobby.lobby_uuid], new_lobby)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:destroy_lobby, lobby_uuid}, state) do
    {_, state} = pop_in(state.lobby_map[lobby_uuid])
    {:noreply, state}
  end
end
