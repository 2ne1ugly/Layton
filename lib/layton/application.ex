defmodule Layton.Application do
  @moduledoc "OTP Application specification for Layton"

  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = [
      Layton.Repo,
      Layton.System.LobbyServer,
      Layton.System.GameSessionServer,
      Layton.System.PlayerServer,
      supervisor(GRPC.Server.Supervisor, [{Layton.Client.Endpoint, 50051}])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Layton.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
