defmodule Publit.Repo.Migrations.AddOrderOrgClientName do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :organization_name, :text
      add :client_name, :text
    end
  end
end
