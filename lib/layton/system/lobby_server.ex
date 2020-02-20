defmodule Layton.System.LobbyServer do
  @moduledoc """
  Server that keeps track on list of lobbies (including on-going ones.)
  """
  use GenServer
  alias __MODULE__

  defstruct pending_lobby_map: %{}, lobby_map: %{}

  #
  # Client Functions
  #

  def create_lobby(player_info, lobby) do
    GenServer.call(__MODULE__, {:create_lobby, player_info, lobby})
  end

  def update_lobby(lobby_uuid, lobby) do
    GenServer.cast(__MODULE__, {:update_lobby, lobby_uuid, lobby})
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
  def handle_call({:get_lobby_stream, lobby_uuid}, _from, state) do
    case Map.get(state.lobby_map, lobby_uuid) do
      nil -> {:reply, :error, state}
      lobby -> {:reply, lobby.lobby_stream, state}
    end
  end

  @impl true
  def handle_cast({:update_lobby, lobby_uuid, lobby}, state) do
    state = update_in(state.lobby_map[lobby_uuid], &struct(&1, Map.from_struct(lobby)))
    {:noreply, state}
  end
end
