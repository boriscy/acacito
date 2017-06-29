defmodule Publit.Repo.Migrations.AddOrdersTimes do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :process_time, :timestamp
      add :transport_time, :timestamp
    end
  end
end
