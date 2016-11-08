defmodule Publit.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS CITEXT"

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :citext
      add :full_name, :string
      add :encrypted_password, :string
      add :organizations, :map, default: "[]"
      add :settings, :map, default: "{}"
      add :extra_data, :map, default: "{}"
      add :locale, :string

      timestamps()
    end

    create unique_index(:users, [:email])
    execute "CREATE INDEX organizations_on_users_index ON users USING GIN (organizations)"
  end
end
