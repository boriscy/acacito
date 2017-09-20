defmodule Publit.ClientApi.OrderControllerTest do
  use PublitWeb.ConnCase, async: false
  alias Publit.{Product}
  require PublitWeb.Gettext
  import Mock

  setup do
    user_client = insert(:user_client)
    org = insert(:organization, open: true)
    conn = build_conn()
    |> assign(:current_user_client, user_client)

    %{conn: conn, user_client: user_client, org: org}
  end
  defp salt, do: Application.get_env(:publit, PublitWeb.Endpoint)[:secret_key_base]

  defp create_products2(org) do
    p1 = insert(:product, organization_id: org.id, publish: true)
    p2 = insert(:product, name: "Super Salad", organization_id: org.id, publish: true,
     variations: [
      %Product.Variation{price: Decimal.new("20.5")}
    ])

    [p1, p2]
  end

  defp order_params(org) do
    [p1, p2] = create_products2(org)
    v1 = Enum.at(p1.variations, 1)
    v2 = Enum.at(p2.variations, 0)

    %{"organization_id" => org.id, "currency" => org.currency,
    "client_pos" => %{"coordinates" => [-120, 30], "type" => "Point"},
    "cli" => %{"address" => "Los Pinos B100"},
    "details" => %{
        "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
        "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
     },
     "trans" => %{"calculated_price" => "3", "ctype" => "delivery"}
    }
  end

  describe "POST /client_api/orders" do
    test_with_mock "OK", %{conn: conn, org: org}, PublitWeb.OrganizationChannel, [],
      [broadcast_order: fn(_ord) -> :ok end] do
      conn = post(conn, "/client_api/orders", %{"order" => order_params(org)})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)
      ord = json["order"]
      assert ord["client_pos"] == %{"coordinates" => [-120, 30], "type" => "Point"}

      assert json["order"]["org"]["name"] == org.name
      assert json["order"]["trans"]["ctype"] == "delivery"

      assert called PublitWeb.OrganizationChannel.broadcast_order(:_)
    end

    test_with_mock "OK pick and pay", %{conn: conn, org: org}, PublitWeb.OrganizationChannel, [],
      [broadcast_order: fn(_ord) -> :ok end] do
      p = Map.put(order_params(org), "trans", %{"calculated_price" => "3", "ctype" => "pickup"})
      conn = post(conn, "/client_api/orders", %{"order" => p})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)
      ord = json["order"]
      assert ord["client_pos"] == %{"coordinates" => [-120, 30], "type" => "Point"}

      assert json["order"]["organization_name"] == org.name
      assert json["order"]["trans"]["ctype"] == "pickup"

      assert called PublitWeb.OrganizationChannel.broadcast_order(:_)
    end

    test "ERROR",%{conn: conn, org: org} do
      order_p = order_params(org) |> Map.delete("client_pos")
      conn = post(conn, "/client_api/orders", %{"order" => order_p})

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      json = Poison.decode!(conn.resp_body)

      assert json["errors"]["client_pos"]
    end

    test "unauthorized" do
      conn = build_conn() |> put_req_header("user_token", Phoenix.Token.sign(PublitWeb.Endpoint, salt(), Ecto.UUID.generate()))

      conn = post(conn, "/client_api/orders", %{"order" => %{}})

      assert conn.status == Plug.Conn.Status.code(:unauthorized)
      json = Poison.decode!(conn.resp_body)

      assert json["message"] == PublitWeb.Gettext.gettext("You need to login")
    end
  end

  describe "GET /client_api/orders/:id" do
    test "OK", %{conn: conn, user_client: user_client, org: org} do
      ord = create_order(user_client, org)

      conn = get(conn, "/client_api/orders/#{ord.id}")

      json = Poison.decode!(conn.resp_body)
      assert json["order"]["id"] == ord.id
      assert json["order"]["details"] |> Enum.count() == 2

      assert json["order"]["organization_id"] == org.id
      assert json["order"]["org"]["name"] == org.name
    end

    test "not found", %{conn: conn} do
      conn = get(conn, "/client_api/orders/#{Ecto.UUID.generate()}")

      assert conn.status == Plug.Conn.Status.code(:not_found)
      json = Poison.decode!(conn.resp_body)

      assert json["error"]
    end
  end


  describe "GET /client_api/orders" do
    test "OK", %{conn: conn, user_client: user_client, org: org} do
      create_order_only(user_client, org)

      conn = get(conn, "/client_api/orders")

      json = Poison.decode!(conn.resp_body)
      assert json["orders"] |> Enum.count() == 1
      ord = List.first json["orders"]

      assert ord["details"] |> Enum.count() == 2

      assert ord["organization_id"] == org.id
      assert ord["org"]["name"] == org.name
    end
  end

end
