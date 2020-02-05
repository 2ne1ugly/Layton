defmodule Layton.Schema.Account do
  use Ecto.Schema

  schema "accounts" do
    field(:username, :string)
  end

  def changeset(account, params \\ %{}) do
    account
    |> Ecto.Changeset.cast(params, [:username])
    |> Ecto.Changeset.validate_length(:username, min: 5, max: 16)
    |> Ecto.Changeset.unique_constraint(:username)
  end
end
