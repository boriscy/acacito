defmodule Publit.Plug.Auth do
  import Plug.Conn
  import Publit.Router.Helpers
  import Phoenix.Controller
  alias Publit.{UserAuth}

  def init(default), do: default

  def call(conn, default) do
    if user(conn) do

    else
      conn
      |> put_flash(:error, "You need to login")
      |> redirect(to: "/login")
      |> halt()
    end
  end

  defp user(conn) do
    if user_id = get_session(conn, :user_id) do
      UserAuth.get_user(conn)
    else
      nil
    end
  end
end
