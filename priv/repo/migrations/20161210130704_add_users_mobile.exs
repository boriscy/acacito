defmodule Publit.Repo.Migrations.AddUsersType do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :mobile_number, :text
    end

    create index(:users, [:mobile_number], unique: true)
  end

end
