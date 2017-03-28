defmodule Publit.OneSignal do
  @moduledoc false
  alias Publit.Repo

  defmacro __using__(_opts) do
    quote do
      def update_os_player_id(user, player_id) do
        if user.extra_data["os_player_id"] == player_id do
          {:ok, user}
        else
          user
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.put_change(:extra_data, Map.merge(user.extra_data, %{
             "os_player_id" => player_id, "os_updated_at" => to_string(DateTime.utc_now)}) )
          |> Repo.update()
        end
      end

      def get_by_email_or_mobile(email_or_mobile) do
        q = from ut in __MODULE__, where: ut.email == ^email_or_mobile or ut.mobile_number == ^email_or_mobile

        Repo.one(q)
      end
    end
  end

end

