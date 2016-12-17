defmodule Publit.Repo.Migrations.AddOrganizationsDescriptionImage do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :description, :string
      add :image, :string
    end
  end
end
