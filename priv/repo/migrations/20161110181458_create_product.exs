defmodule Publit.Repo.Migrations.CreateProduct do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :text, null: false
      add :description, :text
      add :publish, :boolean, default: false, null: false
      add :currency, :text
      add :tags, {:array, :text}, default: []
      add :unit, :text
      add :image, :text
      add :extra_info, :map, default: "{}"

      add :pos, :smallint, default: 1

      add :has_inventory, :boolean, default: true
      add :moderated, :boolean, default: false, null: false

      add :organization_id, references(:organizations, type: :uuid, null: false, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:products, [:organization_id])

  end
end
