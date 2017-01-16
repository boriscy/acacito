defmodule Publit.Repo.Migrations.AddClientTransportToOrders do
  use Ecto.Migration

  def up do
    alter table(:orders) do
      add :user_client_id, references(:user_clients, type: :uuid, null: false, on_delete: :delete_all), null: false
      add :user_transport_id, references(:user_transports, type: :uuid, null: false, on_delete: :delete_all)
    end
    create index(:orders, [:user_client_id])
    create index(:orders, [:user_transport_id])
  end

  def down do
    alter table(:orders) do
      remove :user_client_id
      remove :user_transport_id
    end
  end
end
