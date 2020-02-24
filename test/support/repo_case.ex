defmodule Layton.Test.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias Layton.Repo

      import Ecto
      import Ecto.Query
      import Layton.Test.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Layton.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Layton.Repo, {:shared, self()})
    end

    :ok
  end
end
