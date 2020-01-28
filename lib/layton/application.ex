defmodule Layton.Application do
  @moduledoc "OTP Application specification for Layton"

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      Layton.Repo,
      # Use Plug.Cowboy.child_spec/3 to register our endpoint as a plug
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Layton.Endpoint,
        options: [port: 4001]
      ),
      Layton.Server,
      Layton.Client.Manager
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Layton.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
