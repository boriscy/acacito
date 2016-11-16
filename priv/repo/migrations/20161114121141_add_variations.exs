defmodule Publit.Repo.Migrations.AddVariations do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :variations, :jsonb, default: "[]"
    end
    execute "CREATE INDEX variations_on_products ON products USING GIN (variations)"
  end

  def down do
    execute "DROP INDEX variations_on_products"
    alter table(:products) do
      remove :variations
    end
  end
end
