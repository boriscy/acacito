defmodule Publit.Repo.Migrations.CreateUserTransports do
  use Ecto.Migration

  def change do
    create table(:user_transports, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :citext, null: false
      add :full_name, :text
      add :encrypted_password, :text
      add :settings, :map, default: "{}"
      add :extra_data, :map, default: "{}"
      add :locale, :text
      add :mobile_number, :text

      timestamps()
    end

    create index(:user_transports, [:mobile_number])
  end
end
