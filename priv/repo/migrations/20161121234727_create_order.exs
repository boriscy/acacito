defmodule Publit.Repo.Migrations.CreateOrder do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :user_id, references(:users, type: :uuid, null: false, on_delete: :delete_all), null: false
      add :organization_id, references(:organizations, type: :uuid, null: false, on_delete: :delete_all), null: false
      add :total, :decimal
      add :details, :jsonb, default: "[]"
      add :location, :geometry
      add :messages, :jsonb, default: "[]"
      add :status, :string, null: false
      add :null_reason, :text

      timestamps()
    end

    create index(:orders, [:organization_id])
  end
end
