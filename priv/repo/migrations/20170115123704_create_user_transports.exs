defmodule Publit.Repo.Migrations.CreateUserTransports do
  use Ecto.Migration

  def change do
    create table(:user_transports, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :email, :citext
      add :full_name, :text
      add :encrypted_password, :text
      add :settings, :map, default: "{}"
      add :extra_data, :map, default: "{}"
      add :locale, :text
      add :mobile_number, :text
      add :pos, :geometry
      add :plate, :text
      add :status, :text, default: "off"

      timestamps()
    end

    create index(:user_transports, [:mobile_number], unique: true)
    execute("CREATE INDEX user_transports_on_pos ON user_transports USING GIST (pos)")
  end

  def down do
    drop table(:user_transports)
  end
end
