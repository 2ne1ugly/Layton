defmodule Layton.Object.LobbyStream do
  @moduledoc """
  A Lobby as entity; manages itself and communicates with lobby server
  """
  use GenServer
  alias __MODULE__
  require Logger

  defstruct lobby_name: "",
            lobby_uuid: "",
            map_name: "",
            host_player_username: "",
            player_streams: %{},
            max_players: 10,
            lobby_state: :LS_PENDING

  def join_lobby_stream(pid, player_info, stream) do
    GenServer.call(pid, {:join_lobby_stream, player_info, stream})
  end

  def send_chat_message(pid, player_info, message) do
    GenServer.cast(pid, {:send_chat_message, player_info, message})
  end

  def leave_lobby_stream(pid, player_info) do
    GenServer.cast(pid, {:leave_lobby_stream, player_info})
  end

  #
  # Bindings
  #
  def start([lobby]) do
    GenServer.start(__MODULE__, [lobby])
  end

  @impl true
  def init([lobby]) do
    {:ok, struct(LobbyStream, Map.from_struct(lobby))}
  end

  @impl true
  def handle_call({:join_lobby_stream, player_info, stream}, _from, state) do
    if map_size(state.player_streams) >= state.max_players do
      {:reply, :error, state}
    else
      username = player_info.username

      msg =
        Lgrpc.LobbyStreamServer.new(%{
          message: {:player_joined, Lgrpc.PlayerInfo.new(Map.from_struct(player_info))}
        })

      Enum.each(Map.values(state.player_streams), &GRPC.Server.send_reply(&1.stream, msg))

      state =
        put_in(
          state.player_streams[username],
          %Layton.Types.PlayerStream{stream: stream, player_info: player_info}
        )

      state =
        case state.host_player_username do
          ^username -> put_in(state.lobby_state, :LS_WAITING_FOR_MATCH)
          _ -> state
        end

      Layton.System.LobbyServer.update_lobby(state)
      {:reply, {:ok, state}, state}
    end
  end

  @impl true
  def handle_cast({:send_chat_message, player_info, message}, state) do
    msg =
      Lgrpc.LobbyStreamServer.new(%{
        message:
          {:receive_chat_message,
           Lgrpc.ReceiveChatMessage.new(%{
             username: player_info.username,
             message: message
           })}
      })

    Enum.each(Map.values(state.player_streams), &GRPC.Server.send_reply(&1.stream, msg))
    {:noreply, state}
  end

  @impl true
  def handle_cast({:leave_lobby_stream, player_info}, state) do
    {elem, state} = pop_in(state.player_streams, player_info.username)

    case elem do
      nil ->
        Logger.error("Trying to leave lobby that doesn't exist {player_info.username}")

      %{player_streams: player_streams} when map_size(player_streams) == 0 ->
        Layton.System.LobbyServer.destroy_lobby(state.lobby_uuid)

      _ ->
        Layton.System.LobbyServer.update_lobby(state)
    end

    {:noreply, state}
  end
end
