defmodule Publit.Plug.UserAuth do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  alias Publit.{Repo, Endpoint, User}

  def init(default), do: default

  def call(conn, _default) do
    if !conn.assigns[:current_user] do
      case get_user(conn) do
        {:ok, user} ->
          conn
          |> assign(:current_user, user)
        :error ->
          conn
          |> put_flash(:error, "You need to login")
          |> redirect(to: "/login")
          |> halt()
      end
    else
      conn
    end
  end

  defp get_user(conn) do
    with user_token <- get_session(conn, :user_id),
      {:ok, user_id} <- Phoenix.Token.verify(Endpoint, "user_id", user_token),
      {:ok, user_id} <- Ecto.UUID.cast(user_id) do
        case Repo.get(User, user_id) do
          nil -> :error
          user -> {:ok, user}
        end
    else
      _ -> :error
    end
  end
end
