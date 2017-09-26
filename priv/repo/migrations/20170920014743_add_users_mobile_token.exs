defmodule Publit.Repo.Migrations.AddUserClient do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :mobile_verification_token, :string
      add :mobile_verification_send_at, :timestamp
    end

    alter table(:user_clients) do
      add :mobile_verification_token, :string
      add :mobile_verification_send_at, :timestamp
    end

    alter table(:user_transports) do
      add :mobile_verification_token, :string
      add :mobile_verification_send_at, :timestamp
    end
  end
end
