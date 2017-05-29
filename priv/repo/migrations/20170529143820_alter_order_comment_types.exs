defmodule Publit.Repo.Migrations.AlterOrderComments do
  use Ecto.Migration

  def up do
    alter table(:orders) do
      remove :comment_types
      add :comment_details, :jsonb, default: "{}"
    end
  end

  def down do
    alter table(:orders) do
      remove :comment_details
      add :comment_types, {:array, :text}, default: []
    end
  end
end
