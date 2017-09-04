defmodule Publit.OrderControllerTest do
  use PublitWeb.ConnCase
  import PublitWeb.Gettext

  describe "GET /orders" do
    test "OK", %{conn: conn} do
      conn = build_conn()
      |> set_user_org_conn()

      conn = get(conn, "/orders")

      assert view_template(conn) == "index.html"
      assert conn.status == Plug.Conn.Status.code(:ok)
    end

    test "redirect if incomplete org" do
      conn = build_conn() |> set_user_org_conn(%{org: %{pos: nil}})

      conn = get(conn, "/orders")

      assert conn.private.phoenix_flash["warning"] == gettext("You must set your position.")
      assert redirected_to(conn) == "/organizations/current"
    end
  end
end
