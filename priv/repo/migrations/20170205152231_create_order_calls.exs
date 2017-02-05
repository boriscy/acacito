defmodule Publit.Repo.Migrations.CreateOrderCalls do
  use Ecto.Migration

  def change do
    create table(:order_calls, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :order_id, references(:orders, type: :uuid, null: false, on_delete: :delete_all), null: false

      add :transport_ids, {:array, :text}, default: []

      timestamps()
    end

    execute("CREATE INDEX transport_ids_on_order_calls on order_calls USING GIN (transport_ids)")
  end

  def down do
    drop table(:order_calls)
  end
end
