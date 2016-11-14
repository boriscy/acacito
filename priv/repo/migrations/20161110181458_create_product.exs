defmodule Publit.Repo.Migrations.CreateProduct do
  use Ecto.Migration

  def change do
    create table(:products, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :price, :decimal, precision: 12, scale: 2, default: 0.0
      add :publish, :boolean, default: false, null: false
      add :currency, :string
      add :tags, {:array, :string}
      add :unit, :string
      add :image, :string
      add :extra_info, :map, default: "{}"

      add :pos, :smallint, default: 1

      add :has_inventory, :boolean, default: true
      add :moderated, :boolean, default: false, null: false

      add :organization_id, references(:organizations, type: :uuid, null: false, on_delete: :delete_all), null: false

      timestamps()
    end

  end
end
