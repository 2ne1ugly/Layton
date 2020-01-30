defmodule Layton.Session.Router do
  require Logger

  @spec dispatch_task(map, integer, any) :: {:noreply, any} | {:stop, :normal, any}
  def dispatch_task(content, minor, state) do
    result =
      case minor do
        "createSession" ->
          Layton.Session.CreateSession.process_task(content, state)

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

defmodule Layton.Session.CreateSession do
  @spec process_task(any, any) :: {:ok, any} | {:error, any}
  def process_task(_content, state) do
    {:ok, state}
  end
end
