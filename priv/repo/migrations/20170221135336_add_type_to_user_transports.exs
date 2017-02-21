defmodule Publit.Repo.Migrations.AddTypeToUserTransports do
  use Ecto.Migration

  def change do
    alter table(:user_transports) do
      add :vehicle, :text, null: false, default: "car"
    end
  end
end
