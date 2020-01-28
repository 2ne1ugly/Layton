defmodule Layton.Client.Manager do
  use GenServer
  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opt) do
    port = 8585
    result = :ranch.start_listener(:server, :ranch_tcp, [port: port], Layton.Client, [])
    Logger.info("Listening for connections on port #{port}")
    result
  end
end

defmodule Layton.Client do
  use GenServer
  require Logger

  defstruct transport: nil, peer: nil

  def start_link(ref, socket, transport, _opts) do
    pid = :proc_lib.spawn_link(__MODULE__, :init, [ref, socket, transport])
    {:ok, pid}
  end

  @impl true
  def init(arg) do
    {:ok, arg}
  end

  def init(ref, socket, transport) do
    :ok = :ranch.accept_ack(ref)
    {:ok, {ip_address, port}} = :inet.peername(socket)
    pretty_ip_address = Enum.join(Tuple.to_list(ip_address), ".")

    Logger.info("new connection on #{pretty_ip_address}:#{port}")

    :ok = transport.setopts(socket, [{:active, true}])

    :gen_server.enter_loop(__MODULE__, [], %Layton.Client{
      transport: transport,
      peer: {ip_address, port}
    })
  end

  # Data comes in as 4 byte length
  # And then the rest of it is json

  @impl true
  def handle_info({:tcp, socket, data}, state) do
    state.transport.send(socket, data)
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp_closed, socket}, state) do
    state.transport.close(socket)
    {ip_address, port} = state.peer
    pretty_ip_address = Enum.join(Tuple.to_list(ip_address), ".")
    Logger.info("lost connection on #{pretty_ip_address}:#{port}")
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:tcp_error, socket}, state) do
    state.transport.close(socket)
    {ip_address, port} = state.peer
    pretty_ip_address = Enum.join(Tuple.to_list(ip_address), ".")
    Logger.info("lost connection on #{pretty_ip_address}:#{port}")
    {:stop, :normal, state}
  end
end
