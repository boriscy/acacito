defmodule Publit.Repo.Migrations.AddAddressCommentsToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :client_address, :text
      add :organization_address, :text
      add :comments, :text
    end
  end
end
