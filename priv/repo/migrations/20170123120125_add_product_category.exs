defmodule Publit.Repo.Migrations.AddProductCategory do
  use Ecto.Migration

  def change do
    alter table(:products) do
      add :category, :text
    end
  end
end
