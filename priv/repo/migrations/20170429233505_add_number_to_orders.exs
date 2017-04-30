defmodule Publit.Repo.Migrations.AddNumberToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :client_number, :text
      add :organization_number, :text
    end
  end
end
