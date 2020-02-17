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

  def create_lobby(player, lobby) do
    GenServer.call(__MODULE__, {:create_lobby, player, lobby})
  end

  def find_lobbies() do
    GenServer.call(__MODULE__, :find_lobbies)
  end

  def start_lobby() do
    GenServer.call(__MODULE__, :start_lobby)
  end

  def join_lobby(player, lobby_uuid) do
    GenServer.call(__MODULE__, {:join_lobby, player, lobby_uuid})
  end

  def leave_lobby() do
    GenServer.call(__MODULE__, :leave_lobby)
  end

  #
  # Bindings
  #
  def start_link(_args) do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    {:ok, %LobbyServer{}}
  end

  @impl true
  def handle_call({:create_lobby, player, lobby}, _from, state) do
    lobby = %{lobby |
      lobby_uuid: Ecto.UUID.bingenerate(),
      host_player: player,
      players: [player]
    }
    state = %{ state | lobby_map: Map.put_new(state.lobby_map, lobby.lobby_uuid, lobby) }
    Layton.System.PlayerServer.update_current_lobby(player.username, lobby.lobby_uuid)
    {:reply, lobby.lobby_uuid, state}
  end

  @impl true
  def handle_call(:find_lobbies, _from, state) do
    {:reply, Map.values(state.lobby_map), state}
  end

  @impl true
  def handle_call({:join_lobby, player, lobby_uuid}, _from, state) do
    case Map.get(state.lobby_map, lobby_uuid) do
      nil -> {:reply, :error, state}
      lobby ->
        if length(lobby.players) >= lobby.max_players do
          {:reply, :error, state}
        else
          state = update_in(state.lobby_map[lobby_uuid].players, &(&1 ++ [player]))
          {:reply, :ok, state}
        end
    end
  end
end
