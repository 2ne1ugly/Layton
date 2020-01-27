defmodule Layton.Repo do
  use Ecto.Repo,
    otp_app: :layton,
    adapter: Ecto.Adapters.Postgres
end
