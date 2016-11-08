defmodule Publit.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :currency, :string
      add :info, :map, default: "{}"
      add :settings, :map, default: "{}"

      timestamps
    end
  end
end
