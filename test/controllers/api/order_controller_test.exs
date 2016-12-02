defmodule Publit.Api.OrderControllerTest do
  use Publit.ConnCase
  alias Publit.{Order, ProductVariation}

  setup do
    conn = build_conn
    |> set_user_org_conn()

    %{conn: conn}
  end

  defp create_order(user, org) do
    [p1, p2] = create_products(org)
    v1 = Enum.at(p1.variations, 1)
    v2 = Enum.at(p2.variations, 0)
    params = %{"user_id" => user.id, "organization_id" => org.id, "currency" => org.currency,
    "location" => Geo.WKT.decode("POINT(30 -90)"),
    "details" => %{
        "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
        "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
      }
    }
    {:ok, order} = Order.create(params)
    order
  end
  defp create_products(org) do
    p1 = insert(:product, organization_id: org.id, publish: true)
    p2 = insert(:product, name: "Super Salad", organization_id: org.id, publish: true,
     variations: [
      %ProductVariation{price: Decimal.new("20.5")}
    ])

    [p1, p2]
  end

  defp order_params(conn) do
    %{current_user: user, current_organization: org} = conn.assigns
    [p1, p2] = create_products(org)
    v1 = Enum.at(p1.variations, 1)
    v2 = Enum.at(p2.variations, 0)

    %{"user_id" => user.id, "organization_id" => org.id, "currency" => org.currency,
    "location" => %{"coordinates" => [-120, 30], "type" => "Point"},
    "details" => %{
        "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
        "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
      }
    }
  end

  describe "POST /api/orders" do
    test "OK",%{conn: conn} do
      conn = post(conn, "/api/orders", %{"order" => order_params(conn)})

      assert conn.status == 200
      ord = Poison.decode!(conn.resp_body)["order"]
      assert ord["location"] == %{"coordinates" => [-120, 30], "type" => "Point"}
    end

    test "ERROR",%{conn: conn} do
      order_p = order_params(conn) |> Map.delete("location")
      conn = post(conn, "/api/orders", %{"order" => order_p})

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      json = Poison.decode!(conn.resp_body)
      assert json["errors"]["location"]
    end
  end
end
