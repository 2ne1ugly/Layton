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

  defstruct socket: nil, transport: nil, peer: nil, data: <<>>, username: nil

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
      socket: socket,
      transport: transport,
      peer: {ip_address, port}
    })
  end

  # Data comes in as 4 byte length
  # And then the rest of it is json
  # Each content can be only < 16 MB

  # header = 16 bytes
  # content_size = 4 bytes
  # major_type = 4 bytes
  # minor_type = 4 bytes

  defmacrop server_signiture, do: "SERVER_START###\0"
  defmacrop client_signiture, do: "CLIENT_START###\0"

  @spec send_packet({integer, integer}, any, any) :: any
  def send_packet({major, minor}, packet, state) do
    encoded_packet = Poison.encode!(packet)

    full_data =
      <<server_signiture(), byte_size(encoded_packet)::32, major::32, minor::32,
        encoded_packet::binary>>

    state.transport.send(state.socket, full_data)
  end

  @impl true
  def handle_info({:tcp, _socket, packet}, state) do
    data = state.data <> packet
    header_size = byte_size(client_signiture()) + 12

    case data do
      # match header
      <<header::binary-size(header_size), rest::binary>> ->
        case header do
          <<client_signiture(), content_size::32, major::32, minor::32>>
          when content_size < 0x1000000 ->
            case rest do
              <<content::binary-size(content_size), rest::binary>> ->
                state = %{state | data: rest}
                # decode json
                case Poison.decode(content) do
                  {:ok, content} ->
                    process_content(content, major, minor, state)
                    Logger.info("incorrect json data")

                  {:error, _} ->
                    {:stop, :normal, state}
                end

              _ ->
                {:noreply, state}
            end

          _ ->
            Logger.info("incorrect signiture match")
            {:stop, :normal, state}
        end

      _ ->
        {:noreply, state}
    end
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

  defp process_content(content, major, minor, state) do
    {_status, state} =
      case major do
        0 ->
          Layton.Server.Router

        1 ->
          Layton.Identity.Router.dispatch_task(content, minor, state)

        2 ->
          Layton.Session.Router.dispatch_task(content, minor, state)

        _ ->
          Logger.info("wrong request type")
          {:error, state}
      end

    {:noreply, state}
  end
end
