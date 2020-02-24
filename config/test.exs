use Mix.Config

config :layton, Layton.Repo,
  database: "layton_test",
  username: "layton",
  password: "moobot",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :layton, ecto_repos: [Layton.Repo]
config :grpc, start_server: true
# config :logger, backends: []
