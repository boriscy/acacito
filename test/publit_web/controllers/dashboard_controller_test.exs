defmodule Publit.DashboardControllerTest do
  use PublitWeb.ConnCase

  # https://github.com/elixir-lang/plug/blob/master/test/plug/session/cookie_test.exs
  setup do
    conn = build_conn()
    |> set_user_org_conn()

    %{conn: conn}
  end

  describe "GET /dashboard" do
    test "OK", %{conn: conn} do
      conn = get(conn, "/dashboard")

      assert conn.status == Plug.Conn.Status.code(:ok)
      assert conn.private.phoenix_action == :index
      assert view_template(conn) == "index.html"
    end
  end
end
