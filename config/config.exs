import Config

config :layton, Layton.Repo,
  database: "layton",
  username: "layton",
  password: "moobot",
  hostname: "localhost"

config :layton, ecto_repos: [Layton.Repo]
config :grpc, start_server: true
