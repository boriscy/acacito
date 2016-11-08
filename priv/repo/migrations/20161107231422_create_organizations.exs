defmodule Publit.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS postgis"

    create table(:organizations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :currency, :string
      add :address, :string
      add :info, :map, default: "{}"
      add :settings, :map, default: "{}"
      add :geom, :geometry

      timestamps
    end
  end

  def down do
    drop table(:organizations)

    execute "DROP EXTENSION IF EXISTS postgis"
  end
end
