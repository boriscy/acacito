defmodule Publit.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :order_id, references(:orders, type: :uuid, null: false, on_delete: :delete_all), null: false
      add :from_id, :uuid
      add :to_id, :uuid
      add :comment_type, :text
      add :comment, :text
      add :rating, :smallint

      timestamps()
    end

    create index(:comments, [:from_id])
    create index(:comments, [:to_id])
  end

end
