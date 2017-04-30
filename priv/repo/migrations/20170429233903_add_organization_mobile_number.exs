defmodule Publit.Repo.Migrations.AddOrganizationMobileNumber do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :mobile_number, :text
    end
  end
end
