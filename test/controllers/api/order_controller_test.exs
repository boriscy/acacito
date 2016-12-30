defmodule Publit.Api.OrderControllerTest do
  use Publit.ConnCase
  alias Publit.{ProductVariation, Endpoint}
  require Publit.Gettext

  setup do
    {user, org} = create_user_org()
    conn = build_conn
    |> assign(:current_user, user)

    %{conn: conn, user: user, org: org}
  end
  defp salt, do: Application.get_env(:publit, Publit.Endpoint)[:secret_key_base]

  defp create_products2(org) do
    p1 = insert(:product, organization_id: org.id, publish: true)
    p2 = insert(:product, name: "Super Salad", organization_id: org.id, publish: true,
     variations: [
      %ProductVariation{price: Decimal.new("20.5")}
    ])

    [p1, p2]
  end

  defp order_params(org) do
    [p1, p2] = create_products2(org)
    v1 = Enum.at(p1.variations, 1)
    v2 = Enum.at(p2.variations, 0)

    %{"organization_id" => org.id, "currency" => org.currency,
    "location" => %{"coordinates" => [-120, 30], "type" => "Point"},
    "details" => %{
        "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
        "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
      }, "transport" => %{"calculated_price" => "3"}
    }
  end

  describe "POST /api/orders" do
    test "OK", %{conn: conn, org: org} do
      conn = post(conn, "/api/orders", %{"order" => order_params(org)})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)
      ord = json["order"]
      assert ord["location"] == %{"coordinates" => [-120, 30], "type" => "Point"}

      assert json["order"]["organization"]["name"] == org.name
      assert json["order"]["organization"]["currency"] == "BOB"
    end

    test "ERROR",%{conn: conn, org: org} do
      order_p = order_params(org) |> Map.delete("location")
      conn = post(conn, "/api/orders", %{"order" => order_p})

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      json = Poison.decode!(conn.resp_body)
      assert json["errors"]["location"]
    end

    test "unauthorized" do
      conn = build_conn |> put_req_header("user_token", Phoenix.Token.sign(Endpoint, salt(), Ecto.UUID.generate()))

      conn = post(conn, "/api/orders", %{"order" => %{}})

      assert conn.status == Plug.Conn.Status.code(:unauthorized)
      json = Poison.decode!(conn.resp_body)

      assert json["message"] == Publit.Gettext.gettext("You need to login")
    end
  end

  describe "GET /api/orders/:id" do
    test "OK", %{conn: conn, user: user, org: org} do
      ord = create_order(user, org)

      conn = get(conn, "/api/orders/#{ord.id}")

      json = Poison.decode!(conn.resp_body)
      assert json["order"]["id"] == ord.id
      assert json["order"]["details"] |> Enum.count() == 2

      assert json["order"]["organization"]["id"] == org.id
      assert json["order"]["organization"]["name"] == org.name
    end

    test "not found", %{conn: conn} do
      conn = get(conn, "/api/orders/#{Ecto.UUID.generate()}")

      assert conn.status == Plug.Conn.Status.code(:not_found)
      json = Poison.decode!(conn.resp_body)

      assert json["error"]
    end
  end


  describe "GET /api/user_orders/:user_id" do
    test "OK", %{conn: conn, user: user, org: org} do
      create_order(user, org)

      conn = get(conn, "/api/user_orders/#{user.id}")

      json = Poison.decode!(conn.resp_body)
      assert json["orders"] |> Enum.count() == 1
      ord = List.first json["orders"]

      assert ord["details"] |> Enum.count() == 2

      assert ord["organization"]["id"] == org.id
      assert ord["organization"]["name"] == org.name
    end
  end

end
