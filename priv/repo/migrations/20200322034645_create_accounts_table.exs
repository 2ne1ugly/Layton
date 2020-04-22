defmodule Layton.Repo.Migrations.CreateAccountsTable do
  use Ecto.Migration

  def change do
    create table("accounts") do
      add :username, :string, size: 16, primary_key: true, null: false
    end

  end
end
