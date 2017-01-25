defmodule Publit.Firebase do
  @moduledoc false
  alias Publit.Repo

  defmacro __using__(_opts) do
    quote do
      def update_fb_token(user, fb_token) do
        if user.extra_data["fb_token"] == fb_token do
          {:ok, user}
        else
          user
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.put_change(:extra_data, Map.merge(user.extra_data, %{
             "fb_token" => fb_token, "fb_token_updated_at" => to_string(DateTime.utc_now)}) )
          |> Repo.update()
        end
      end
    end
  end

end
