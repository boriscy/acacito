defmodule Publit.Repo.Migrations.AddUserTransportsOrders do
  use Ecto.Migration

  def change do
    alter table(:user_transports) do
      add :orders, :jsonb, default: "[]"
    end
  end
end
