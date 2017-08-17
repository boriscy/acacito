defmodule Publit.Repo.Migrations.AddOrdersClientOrgObject do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      add :prev_status, :text
      add :cli, :map, default: "{}"
      add :org, :map, default: "{}"
      add :trans, :map, default: "{}"
    end
  end
end
