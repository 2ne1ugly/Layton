defmodule Layton.Router.Session do
  require Logger

  def dispatch_task(content, minor, state) do
    case minor do
      0 ->
        Layton.Router.Session.CreateSession.process_task(content, state)

      1 ->
        Layton.Router.Session.FindSessions.process_task(content, state)

      2 ->
        Layton.Router.Session.JoinSession.process_task(content, state)

      _ ->
        Logger.info("wrong dispatch")
        {:error, :wrong_dispatch, state}
    end
  end
end

defmodule Layton.Router.Session.CreateSession do
  defstruct session: %Layton.Types.Session{}
  require Logger

  @moduledoc """
  Logs into the system
  Possible Result Codes:
    0 -> fail
    1 -> success
    2 -> error
  """
  def process_task(raw_content, state) do
    case Layton.Utils.json_to_struct(__MODULE__, raw_content) do
      :error ->
        Logger.error("Failed to parse json")
        {:error, :json_error, state}

      content ->
        case Layton.SessionServer.add_session(content.session) do
          {:error, _reason} ->
            Layton.Client.send_packet({2, 0}, %{resultCode: 0}, state)
            {:ok, state}

          :ok ->
            Layton.Client.send_packet({2, 0}, %{resultCode: 1}, state)
            {:ok, state}
        end
    end
  end
end

defmodule Layton.Router.Session.FindSessions do
  defstruct session: %Layton.Types.Session{}
  require Logger

  @moduledoc """
  Logs into the system
  Possible Result Codes:
    0 -> fail
    1 -> success
    2 -> error
  """
  def process_task(raw_content, state) do
    case Layton.Utils.json_to_struct(__MODULE__, raw_content) do
      :error ->
        Logger.error("Failed to parse json")
        {:error, :json_error, state}

      _content ->
        sessions_list = Map.values(Layton.SessionServer.get_session_map())
        Layton.Client.send_packet({2, 1}, %{resultCode: 1, sessions: sessions_list}, state)
        {:ok, state}
    end
  end
end

defmodule Layton.Router.Session.JoinSession do
  defstruct name: SessionName
  require Logger

  @moduledoc """
  Logs into the system
  Possible Result Codes:
    0 -> fail
    1 -> success
    2 -> error
  """
  def process_task(raw_content, state) do
    case Layton.Utils.json_to_struct(__MODULE__, raw_content) do
      :error ->
        Logger.error("Failed to parse json")
        {:error, :json_error, state}

      _content ->
        sessions_list = Map.values(Layton.SessionServer.get_session_map())
        Layton.Client.send_packet({2, 1}, %{resultCode: 1, sessions: sessions_list}, state)
        {:ok, state}
    end
  end
end

