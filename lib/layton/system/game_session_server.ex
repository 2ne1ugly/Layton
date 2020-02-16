defmodule Layton.System.LobbySessionServer do
  @moduledoc """
  Server that keeps track on list of lobbies (including on-going ones.)
  """
  use GenServer
  alias __MODULE__

  defstruct session_map: %{}

  #
  # Client Functions
  #

  def create_session(session) do
    GenServer.call(__MODULE__, {:create_session, session})
  end

  def find_sessions() do
    GenServer.call(__MODULE__, :find_sessions)
  end

  def start_session() do
    GenServer.call(__MODULE__, :start_session)
  end

  def join_session() do
    GenServer.call(__MODULE__, :join_session)
  end

  def leave_session() do
    GenServer.call(__MODULE__, :leave_session)
  end

  #
  # Bindings
  #
  def start_link(_args) do
    GenServer.start(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    {:ok, %LobbySessionServer{}}
  end

  @impl true
  def handle_call({:create_session, session}, _from, state) do
    if Map.has_key?(state.session_map, session.session_name) do
      {:reply, {:error, :already_exists}, state}
    else
      state = %{
        state
        | session_map: Map.put_new(state.session_map, session.session_name, session)
      }

      {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call({:find_sessions, session}, _from, state) do
    {:reply, session.session_map, state}
  end
end

defmodule Layton.Types.Session do
  defstruct session_name: ""
end
