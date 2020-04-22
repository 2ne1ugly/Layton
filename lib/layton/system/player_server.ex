defmodule Layton.System.PlayerServer do
  @moduledoc """
  Server that keeps track on all online players
  """
  use GenServer
  alias __MODULE__

  defstruct player_map: %{}

  def login_player(player) do
    GenServer.call(__MODULE__, {:login_player, player})
  end

  def update_current_lobby(username, lobby_uuid) do
    GenServer.cast(__MODULE__, {:update_current_lobby, username, lobby_uuid})
  end

  def fetch_online_player(username, auth_token) do
    GenServer.call(__MODULE__, {:fetch_online_player, username, auth_token})
  end

  #
  # iex helpers
  #

  def list_players() do
    GenServer.call(__MODULE__, :list_players)
  end

  #
  # Bindings
  #
  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    {:ok, %PlayerServer{}}
  end

  @impl true
  def handle_call({:login_player, player}, _from, state) do
    result =
      case Map.has_key?(state.player_map, player.player_info.username) do
        true -> :already_logged_in
        false -> :ok
      end

    player = put_in(player.auth_token, Ecto.UUID.generate())
    state = put_in(state.player_map[player.player_info.username], player)
    {:reply, {result, player.auth_token}, state}
  end

  @impl true
  def handle_call({:fetch_online_player, username, auth_token}, _from, state) do
    case Map.fetch(state.player_map, username) do
      {:ok, player} ->
        case player.auth_token do
          ^auth_token -> {:reply, {:ok, player}, state}
          _ -> {:reply, :error, state}
        end

      :error ->
        {:reply, :error, state}
    end
  end

  @impl true
  def handle_call(:list_players, _from, state) do
    {:reply, Map.values(state.player_map), state}
  end

  @impl true
  def handle_cast({:update_current_lobby, username, lobby_uuid}, state) do
    case Map.fetch(state.player_map, username) do
      :error ->
        {:noreply, state}

      {:ok, player} ->
        player = put_in(player.lobby_uuid, lobby_uuid)
        state = put_in(state.player_map[username], player)
        {:noreply, state}
    end
  end
end
