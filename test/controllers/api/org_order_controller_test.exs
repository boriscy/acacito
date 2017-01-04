defmodule Publit.Api.OrgOrderControllerTest do

  use Publit.ConnCase
  require Publit.Gettext

  setup do
    {user, org} = create_user_org()
    conn = build_conn
    |> assign(:current_user, user)
    |> assign(:current_organization, org)

    %{conn: conn, user: user, org: org}
  end

  describe "GET /api/org_orders" do
    test "OK", %{conn: conn, user: user, org: org} do
      create_order(user, org)

      conn = get(conn, "/api/org_orders")

      json = Poison.decode!(conn.resp_body)
      assert json["orders"] |> Enum.count() == 1

      order = json["orders"] |> List.first()
      assert order["user"]["id"] == user.id
      assert order["user"]["full_name"] == user.full_name
    end

    test "not found", %{conn: conn} do
      conn = get(conn, "/api/org_orders/#{Ecto.UUID.generate()}")

      assert conn.status == Plug.Conn.Status.code(:not_found)
      json = Poison.decode!(conn.resp_body)

      assert json["error"]
    end
  end

  describe "GET /api/org_orders/:id" do
    test "OK", %{conn: conn, user: user, org: org} do
      ord = create_order(user, org)

      conn = get(conn, "/api/org_orders/#{ord.id}")

      json = Poison.decode!(conn.resp_body)
      assert json["order"]["id"] == ord.id
      assert json["order"]["details"] |> Enum.count() == 2

      assert json["order"]["user"]["id"] == user.id
      assert json["order"]["user"]["full_name"] == user.full_name
    end

    test "not found", %{conn: conn} do
      conn = get(conn, "/api/orders/#{Ecto.UUID.generate()}")

      assert conn.status == Plug.Conn.Status.code(:not_found)
      json = Poison.decode!(conn.resp_body)

      assert json["error"]
    end
  end

  describe "PUT /api/org_orders/:id/move_next" do
    test "OK", %{conn: conn, user: user, org: org} do
      ord = create_order(user, org)

      assert ord.status == "new"
      conn = put(conn, "/api/org_orders/#{ord.id}/move_next")

      json = Poison.decode!(conn.resp_body)

      assert json["order"]["status"] == "process"

      assert json["order"]["organization"] == nil
    end
  end
end
