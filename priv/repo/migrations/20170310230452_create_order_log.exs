defmodule Publit.Repo.Migrations.CreateOrderLog do
  use Ecto.Migration

  def change do
    create table(:order_logs, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :order_id, references(:orders, type: :uuid, on_delete: :delete_all), null: false
      add :log_type, :text
      add :log, {:array, :jsonb}, default: []

      timestamps()
    end

    create index(:order_logs, [:order_id, :log_type])
  end
end
