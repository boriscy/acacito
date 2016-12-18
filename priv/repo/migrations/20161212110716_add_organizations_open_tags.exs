defmodule Publit.Repo.Migrations.AddOrganizationsOpenTags do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :open, :boolean, default: false
      add :tags, :jsonb, default: "[]"
    end
    execute "CREATE INDEX tags_on_organizations ON organizations USING GIN (tags)"
  end

  def down do
    execute "DROP INDEX tags_on_organizations"
    alter table(:organizations) do
      remove :open
      remove :tags
    end
  end
end
