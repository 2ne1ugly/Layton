# defmodule Layton.Server do
#   @moduledoc """
#   Main Module for keeping centrual information for online server backend
#   All argument inputs shouldn't be raw json objects.
#   """
#   use GenServer

#   defstruct sessions: %{}

#   # Lifecycle Callabacks

#   def start_link(default) when is_list(default) do
#     GenServer.start_link(__MODULE__, default, name: __MODULE__)
#   end

#   def create_session(request_header, session_settings) do
#     GenServer.call(__MODULE__, {:create_session, request_header, session_settings})
#   end

#   # Server Functions

#   @impl true
#   def init(_init_arg) do
#     state = %Layton.Server{}
#     {:ok, state}
#   end

#   @impl true
#   def handle_call({:create_session, _request_header, session_settings}, _from, state) do
#     # check if key exists
#     if Map.has_key?(state.sessions, session_settings.name) do
#       {:reply, :error, state}
#     end

#     # insert it to the sessions map
#     Map.put(state.sessions, session_settings.name, session_settings)
#     {:reply, :ok, state}
#   end
# end
