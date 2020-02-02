defmodule Layton.Router.Identity do
  use Plug.Router
  require Logger
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(Plug.Logger, log: :debug)
  plug(:dispatch)

  post "/Identity/CreateAccount" do
    {status, body} = Layton.Router.Identity.CreateAccount.process(conn.body_params)
    send_resp(conn, status, body)
  end

  post "/Identity/Login" do
    {status, body} = Layton.Identity.Login.process(conn.body_params)
    send_resp(conn, status, body)
  end

  match _ do
    send_resp(conn, 404, "oops... Nothing here :(")
  end

  def dispatch_task(_content, minor, state) do
    case minor do
      _ ->
        Logger.info("wrong dispatch")
        {:error, :wrong_dispatch, state}
    end
  end
end

defmodule Layton.Router.Identity.CreateAccount do
  defstruct account: %Layton.Account{}
  require Logger
  @moduledoc """
  Creates Account
  Possible Result Codes:
    0 -> fail
    1 -> success
    2 -> error
  """
  @spec process(any) :: {integer, binary}
  def process(body) do
    {status, raw_body} =
      case Layton.Utils.json_to_struct(__MODULE__, body) do
        :error ->
          {400, %{resultCode: 2}}

        request_body ->
          changeset = Layton.Account.changeset(request_body.account)

          case Layton.Repo.insert(changeset) do
            {:ok, _} -> {200, %{resultCode: 1}}
            {:error, _} -> {200, %{resultCode: 0}}
          end
      end

    {status, Poison.encode!(raw_body)}
  end
  def help() do
    Logger.info("save me")
  end
end

defmodule Layton.Identity.Login do
  defstruct credentials: %Layton.Types.Credentials{}

  @moduledoc """
  Logs into the system
  Possible Result Codes:
    0 -> fail
    1 -> success
    2 -> error
  """
  @spec process(any) :: {integer, binary}
  def process(body) do
    {status, raw_body} =
      case Layton.Utils.json_to_struct(__MODULE__, body) do
        :error ->
          {400, %{resultCode: 2}}

        request_body ->
          case Layton.Repo.get_by(Layton.Account, Map.from_struct(request_body.credentials)) do
            nil ->
              {200, %{resultCode: 0}}

            account ->
              {200, %{resultCode: 1, requestHeader: %{username: account.username, token: ""}}}
          end
      end

    {status, Poison.encode!(raw_body)}
  end
end
