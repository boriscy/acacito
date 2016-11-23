defmodule Publit.OrderControllerTest do
  use Publit.ConnCase

  setup do
    conn = build_conn
    |> set_user_org_conn()

    %{conn: conn}
  end

  describe "GET /orders" do
    test "OK", %{conn: conn} do
      conn = get(conn, "/orders")

      assert view_template(conn) == "index.html"
      assert conn.status == Plug.Conn.Status.code(:ok)
    end
  end
end
