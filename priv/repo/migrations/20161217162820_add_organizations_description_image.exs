defmodule Publit.Repo.Migrations.AddOrganizationsDescriptionImage do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :description, :text
      add :images, :jsonb, default: "{}"
      add :rating, :decimal, precision: 3, scale: 1, default: 0
      add :rating_count, :int, default: 0
    end

    create index(:organizations, [:rating])
  end
end
