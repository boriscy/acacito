defmodule Publit.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS CITEXT"

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :citext, null: false
      add :full_name, :text
      add :encrypted_password, :text
      add :organizations, :map, default: "[]"
      add :settings, :map, default: "{}"
      add :extra_data, :map, default: "{}"
      add :locale, :text

      timestamps()
    end

    create unique_index(:users, [:email])
    execute "CREATE INDEX organizations_on_users_index ON users USING GIN (organizations)"
  end

  def down do
    drop table(:users)
    execute "DROP EXTENSION IF EXISTS CITEXT"
  end
end
