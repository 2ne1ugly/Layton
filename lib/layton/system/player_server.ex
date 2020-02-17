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

  def verify_auth_token(username, auth_token) do
    GenServer.call(__MODULE__, {:verify_auth_token, username, auth_token})
  end

  def list_players() do
    GenServer.call(__MODULE__, :list_players)
  end

  #
  # Bindings
  #
  def start_link(_args) do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    {:ok, %PlayerServer{}}
  end

  @impl true
  def handle_call({:login_player, player}, _from, state) do
    result =
      case Map.has_key?(state.player_map, player.username) do
        true -> :already_logged_in
        false -> :ok
      end
    player = put_in(player.auth_token, Ecto.UUID.bingenerate())
    state = put_in(state.player_map[player.username], player)
    {:reply, {result, player.auth_token}, state}
  end

  @impl true
  def handle_call({:verify_auth_token, username, auth_token}, _from, state) do
    reply =
      case Map.fetch(state.player_map, username) do
        :error -> :error
        {:ok, player} ->
          if player.auth_token == auth_token do
            {:ok, player}
          else
            :error
          end
      end
    {:reply, reply, state}
  end

  @impl true
  def handle_call(:list_players, _from, state) do
    {:reply, state.player_map, state}
  end

  @impl true
  def handle_cast({:update_current_lobby, username, lobby_uuid}, state) do
    state =
      case Map.fetch(state.player_map, username) do
        :error -> state
        {:ok, player} -> put_in(state.player_map[username], %{player | lobby_uuid: lobby_uuid})
      end
    {:noreply, state}
  end
end
