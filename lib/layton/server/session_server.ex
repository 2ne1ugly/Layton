defmodule Layton.SessionServer do
  @moduledoc """
  Keeps Track on existing Sessions
  """
  defstruct session_map: %{}

  use GenServer

  def add_session(session) do
    GenServer.call(__MODULE__, {:add_session, session})
  end

  def get_session_map() do
    GenServer.call(__MODULE__, :get_session_map)
  end

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opt) do
    {:ok, %Layton.SessionServer{}}
  end

  @impl true
  def handle_call({:add_session, session}, _from, state) do
    if Map.has_key?(state.session_map, session.name) do
      {:reply, {:error, :already_exists}, state}
    else
      state = %{state | session_map: Map.put_new(state.session_map, session.name, session)}
      {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call(:get_session_map, _from, state) do
    {:reply, state.session_map, state}
  end
end

defmodule Layton.SessionServer.Session do
  defstruct name: ""
end
