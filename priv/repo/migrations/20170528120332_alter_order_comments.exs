defmodule Publit.Repo.Migrations.AlterOrderComments do
  use Ecto.Migration

  def up do
    rename(table(:orders), :comments, to: :other_details)
    alter table(:orders) do
      add :comment_types, {:array, :text}, default: []
    end
  end

  def down do
    rename(table(:orders), :other_details, to: :comments)
    alter table(:orders) do
      remove :comment_types
    end
  end
end
