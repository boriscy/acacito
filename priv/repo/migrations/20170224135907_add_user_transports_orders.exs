defmodule Publit.Repo.Migrations.AddUserTransportsOrders do
  use Ecto.Migration

  def change do
    alter table(:user_transports) do
      add :orders, :jsonb, default: "[]"
    end
    execute "CREATE INDEX orders_on_user_transports ON user_transports USING GIN (orders)"
  end
end
