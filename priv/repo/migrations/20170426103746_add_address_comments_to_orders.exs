defmodule Publit.Repo.Migrations.AddAddressCommentsToOrders do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :address, :text
      add :comments, :text
    end
  end
end
