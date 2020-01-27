# defmodule Layton.Session.Router do
#   use Plug.Router
#   plug(:match)
#   plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
#   plug(Plug.Logger, log: :debug)
#   plug(:dispatch)

#   post "/Session/CreateSession" do
#     {status, body} = Layton.Session.CreateSession.process(conn.body_params)
#     send_resp(conn, status, body)
#   end

#   match _ do
#     send_resp(conn, 404, "oops... Nothing here :(")
#   end
# end

# defmodule Layton.Session.CreateSession do
#   defstruct request_header: %Layton.Types.RequestHeader{}, session_settings: %Layton.Types.SessionSettings{}
#   @doc """
#   Creates Game Session
#   Possible Result Codes:
#     0 -> fail
#     1 -> success
#     2 -> error
#   """
#   def process(body) do
#     {status, raw_body} =
#       case Layton.Utils.json_to_struct(__MODULE__, body) do
#         :error -> {400, %{resultCode: 2}}
#         request_body ->
#           case Layton.Server.create_session(request_body.request_header, request_body.session_settings) do
#             :error -> {200, %{resultCode: 0}}
#             :ok -> {200, %{requestCode: 1}}
#             _ -> {500, %{requestCode: 2}}
#           end
#       end
#     {status, Poison.encode!(raw_body)}
#   end
# end
