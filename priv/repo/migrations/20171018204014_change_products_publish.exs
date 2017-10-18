defmodule Publit.Repo.Migrations.ChangeProductsPublish do
  use Ecto.Migration

  def change do
    rename table("products"), :publish, to: :published
  end
end
