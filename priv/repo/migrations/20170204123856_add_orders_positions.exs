defmodule Publit.Repo.Migrations.AddOrdersPositions do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :client_pos, :geometry
      add :organization_pos, :geometry
    end

    execute "CREATE INDEX client_pos_on_orders ON orders USING GIST (client_pos)"
    execute "CREATE INDEX organization_pos_on_orders ON orders USING GIST (organization_pos)"
  end
end
