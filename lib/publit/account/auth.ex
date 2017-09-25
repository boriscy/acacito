defmodule Publit.Account.Auth do
  @moduledoc false
  alias Publit.Repo


  defmacro __using__(_opts) do
    quote do
      @mobile_number_reg ~r|^[6,7]\d{7}$|

      def update_device_token(user, device_token) do
        if user.extra_data["device_token"] == device_token do
          {:ok, user}
        else
          user
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.put_change(:extra_data, Map.merge(user.extra_data, %{
             "device_token" => device_token, "device_token_updated_at" => to_string(DateTime.utc_now)}) )
          |> Repo.update()
        end
      end

      def get_by_email_or_mobile(email_or_mobile) do
        q = from u in __MODULE__, where: (u.email == ^email_or_mobile or u.mobile_number == ^email_or_mobile) and u.verified == ^true
        Repo.one(q)
      end

      def get_verified(mobile_number) do
        q = from u in __MODULE__, where: (u.mobile_number == ^mobile_number) and u.verified == ^true
        Repo.one(q)
      end

      def create_changeset(struct, params) do
        struct
        |> cast(params, [:full_name, :mobile_number])
        |> validate_required([:full_name, :mobile_number])
        |> validate_length(:full_name, min: 4)
        |> validate_format(:mobile_number, @mobile_number_reg)
        |> unique_constraint(:mobile_number)
      end

      def check_mobile_verification_token(mobile_number, token) do
        with u <- Repo.get_by(__MODULE__, mobile_number: mobile_number),
          false <- is_nil(u),
          true <- u.mobile_verification_token == token  && NaiveDateTime.diff(NaiveDateTime.utc_now, u.mobile_verification_send_at) <= 3600 do
            Ecto.Changeset.change(u)
            |> put_change(:verified, true)
            |> put_change(:mobile_verification_token, "V" <> token)
            |> Repo.update()
        else
          _ ->
            :error
        end
      end

    end
  end

end

