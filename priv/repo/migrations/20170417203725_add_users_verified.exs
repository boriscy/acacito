defmodule Publit.Repo.Migrations.AddUsersVeryfied do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :verified, :boolean, default: false
    end
    alter table(:user_clients) do
      add :verified, :boolean, default: false
    end
    alter table(:user_transports) do
      add :verified, :boolean, default: false
    end
  end
end
