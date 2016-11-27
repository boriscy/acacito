defmodule Publit.Repo.Migrations.CreateOrder do
  use Ecto.Migration

  def up do
    create table(:orders, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, null: false, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, null: false, on_delete: :delete_all), null: false
      add :total, :decimal
      add :location, :geometry
      add :details, :jsonb, default: "[]"
      add :messages, :jsonb, default: "[]"
      add :log, :jsonb, default: "[]"
      add :extra_data, :jsonb, default: "{}"
      add :status, :string, null: false
      add :null_reason, :text
      add :number, :integer
      add :currency, :string


      timestamps()
    end

    create index(:orders, [:organization_id])
    create index(:orders, [:user_id])
    create index(:orders, [:inserted_at])
    create index(:orders, [:updated_at])
    execute "CREATE INDEX details_on_orders ON orders USING GIN (details)"
  end

  def down do
    execute "DROP INDEX details_on_orders"
    drop table(:orders)
  end

end
