defmodule Publit.Api.OrderControllerTest do

  use Publit.ConnCase
  require Publit.Gettext

  setup do
    {user, org} = create_user_org()
    conn = build_conn()
    |> assign(:current_user, user)
    |> assign(:current_organization, org)

    %{conn: conn, user: user, org: org}
  end

  describe "GET /api/orders" do
    test "OK", %{conn: conn, org: org} do
      user_client = insert(:user_client)
      create_order(user_client, org)

      conn = get(conn, "/api/orders")

      json = Poison.decode!(conn.resp_body)
      assert json["orders"] |> Enum.count() == 1

      order = json["orders"] |> List.first()
      assert order["user_client"]["id"] == user_client.id
      assert order["user_client"]["full_name"] == user_client.full_name
    end

    test "not found", %{conn: conn} do
      conn = get(conn, "/api/orders/#{Ecto.UUID.generate()}")

      assert conn.status == Plug.Conn.Status.code(:not_found)
      json = Poison.decode!(conn.resp_body)

      assert json["error"]
    end
  end

  describe "GET /api/orders/:id" do
    test "OK", %{conn: conn, org: org} do
      user_client = insert(:user_client)
      ord = create_order(user_client, org)

      conn = get(conn, "/api/orders/#{ord.id}")

      json = Poison.decode!(conn.resp_body)
      assert json["order"]["id"] == ord.id
      assert json["order"]["details"] |> Enum.count() == 2

      assert json["order"]["user_client"]["id"] == user_client.id
      assert json["order"]["user_client"]["full_name"] == user_client.full_name
    end

    test "not found", %{conn: conn} do
      conn = get(conn, "/api/orders/#{Ecto.UUID.generate()}")

      assert conn.status == Plug.Conn.Status.code(:not_found)
      json = Poison.decode!(conn.resp_body)

      assert json["error"]
    end
  end

  describe "PUT /api/orders/:id/move_next" do
    test "OK", %{conn: conn, org: org} do
      user_client = insert(:user_client)
      ord = create_order(user_client, org)

      assert ord.status == "new"
      conn = put(conn, "/api/orders/#{ord.id}/move_next")

      json = Poison.decode!(conn.resp_body)

      assert json["order"]["status"] == "process"

      assert json["order"]["organization"] == nil
    end
  end
end
