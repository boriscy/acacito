defmodule Publit.Repo.Migrations.AddOrdersPositions do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      remove :pos
      add :client_pos, :geometry
      add :organization_pos, :geometry
      add :transport_pos, :geometry
    end

    execute "CREATE INDEX client_pos_on_orders ON orders USING GIST (client_pos)"
    execute "CREATE INDEX organization_pos_on_orders ON orders USING GIST (organization_pos)"
    execute "CREATE INDEX transport_pos_on_orders ON orders USING GIST (transport_pos)"
  end
end
