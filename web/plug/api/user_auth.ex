defmodule Publit.Plug.Api.UserAuth do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2, render: 3]
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
          |> put_status(:unauthorized)
          |> render(Publit.Api.SessionView, "login.json")
          |> halt()
      end
    else
      conn
    end
  end

  defp get_user(conn) do
    with [user_token] <- get_req_header(conn, "user_token"),
      {:ok, user_id} <- Phoenix.Token.verify(Endpoint, salt(), user_token),
      {:ok, user_id} <- Ecto.UUID.cast(user_id),
      user <- Repo.get(User, user_id),
      false <- is_nil(user) do
        {:ok, user}
    else
      _ -> :error
    end
  end

  defp salt, do: Application.get_env(:publit, Publit.Endpoint)[:secret_key_base]
end
