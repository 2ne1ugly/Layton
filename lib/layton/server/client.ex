defmodule Layton.Client.Manager do
@moduledoc """
responsible for creating sockets
"""
  use GenServer

  defstruct listen_socket: nil
  # Client Functions

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def accept_socket() do
    GenServer.cast(__MODULE__, {:accept_socket})
  end


  # Server Functions

  @impl true
  def init([]) do
    state = %Layton.Client.Manager{}
    case :gen_tcp.listen(8585,[:binary]) do
      {:ok, listen_socket} ->
        IO.inspect(listen_socket)
        {:ok, %{state | listen_socket: listen_socket}}
        # case :gen_tcp.accept(listen_socket) do
        #   {:ok, socket} -> {:ok, %{state | socket: socket}}
        #   {:error, reason} -> IO.inspect(label: "connection closed due to #{reason}")
        # end
      {:error, reason} -> IO.inspect(label: "listen failed due to #{reason}")
    end
  end

  @impl true
  def handle_cast({:accept_socket}, state) do
    Layton.Client.start_link([state.listen_socket])
    {:noreply, state}
  end
end

defmodule Layton.Client do
    @moduledoc """
    representation of each sockets
    """
      use GenServer
    
      defstruct socket: nil
      # Client Functions
    
      def start_link([listen_socket]) do
        GenServer.start_link(__MODULE__, [listen_socket])
      end
    
      # Server Functions
    
      @impl true
      def init([listen_socket]) do
        state = %Layton.Client{}
        case :gen_tcp.accept(listen_socket, 10000) do
            {:error, reason} ->
                IO.inspect(label: "accept failed due to #{reason}")
                {:error, reason}
            {:ok, socket} -> {:ok, %{state | socket: socket}}
        end
      end
    
      @impl true
      def handle_cast({:accept_socket}, state) do
        :gen_tcp.accept(state.listen_socket)
        {:noreply, state}
      end
    
      @impl true
      def handle_info({:tcp, socket, packet}, state) do
        IO.inspect(packet, label: "incoming packet")
        :gen_tcp.send(socket,"Hi Blackode \n")
        {:noreply, state}
      end
    
      @impl true
      def handle_info({:tcp_closed, _socket}, state) do
        IO.inspect("Socket has been closed")
        {:noreply, state}
      end
    
      @impl true
      def handle_info({:tcp_error, socket, reason}, state) do
        IO.inspect(socket, label: "connection closed due to #{reason}")
        {:noreply, state}
      end
    
    end
