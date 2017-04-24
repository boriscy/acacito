defmodule Publit.Repo.Migrations.AddVerified do
  use Ecto.Migration

  def up do
    alter table(:users), do: modify :mobile_number, :text, null: false
    alter table(:user_clients) do
      modify :email, :citext, null: true
      modify :mobile_number, :text, null: false
    end
    alter table(:user_transports), do: modify :mobile_number, :text, null: false
  end

  def down do
    alter table(:users), do: modify :mobile_number, :text, null: true
    alter table(:user_clients) do
      modify :email, :citext, null: false
      modify :mobile_number, :text, null: true
    end
    alter table(:user_transports), do: modify :mobile_number, :text, null: true
  end
end
