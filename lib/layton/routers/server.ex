defmodule Layton.Server.Router do
  require Logger

  @spec dispatch_task(map, integer, any) :: {:noreply, any} | {:stop, :normal, any}
  def dispatch_task(content, minor, state) do
    result =
      case minor do
        0 ->
          Layton.Server.AuthorizeSocket.process_task(content, state)

        _ ->
          Logger.info("wrong dispatch")
          {:error, :wrong_dispatch}
      end

    case result do
      {:ok, state} -> {:noreply, state}
      {:error, _reason} -> {:stop, :normal, state}
    end
  end
end

defmodule Layton.Server.AuthorizeSocket do
  defstruct username: nil, token: nil

  @moduledoc """
  Logs into the system
  Possible Result Codes:
    0 -> fail
    1 -> success
    2 -> error
  """
  @spec process_task(any, any) :: {:ok, any} | {:error, any}
  def process_task(content, state) do
    case Layton.Utils.json_to_struct(__MODULE__, content) do
      :error ->
        Layton.Client.send_packet({0, 0}, %{resultCode: 2}, state)
        {:error, state}

      request_body ->
        Layton.Client.send_packet({0, 0}, %{resultCode: 1}, state)
        state = Map.put(state, :username, request_body.username)
        {:ok, state}
    end
  end
end
