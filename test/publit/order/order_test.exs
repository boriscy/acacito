defmodule Publit.OrderTest do
  use Publit.ModelCase
  import Publit.Support.Session, only: [create_user_org: 1]

  alias Publit.{Order, Product, Repo}

  defp create_products2(org) do
    p1 = insert(:product, organization_id: org.id, publish: true)
    p2 = insert(:product, name: "Super Salad", organization_id: org.id, publish: true,
     variations: [
      %Product.Variation{price: Decimal.new("20.5")}
    ])

    [p1, p2]
  end


  describe "create" do
    test "OK" do
      org = insert(:organization, open: true)
      user_client = insert(:user_client)
      [p1, p2] = create_products2(org)
      v1 = Enum.at(p1.variations, 1)
      v2 = Enum.at(p2.variations, 0)

      params = %{"user_client_id" => user_client.id, "organization_id" => org.id, "currency" => org.currency,
      "client_pos" => %{"coordinates" => [-100, 30], "type" => "Point"},
      "cli" => %{"address" => "Los Pinos, B777"},
      "other_details" => "cambio de 200",
      "details" => %{
          "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1", "image_thumb" => "thumb1.jpg", "details" => "Con aji"},
          "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2", "image_thumb" => "thumb2.jpg"}
        },
        "trans" => %{"ctype" => "delivery", "calculated_price" => "5"}
      }

      assert {:ok, order} = Order.create(params, user_client)

      assert order.client_pos == %Geo.Point{coordinates: {-100, 30}, srid: nil}
      assert order.organization_pos == org.pos

      assert order.num == 1
      assert order.total == Decimal.new("71.0")
      assert order.currency == org.currency
      assert order.status == "new"
      assert order.other_details == "cambio de 200"
      assert order.trans.ctype == "delivery"

      assert order.user_client_id == user_client.id
      assert order.cli.name == user_client.full_name
      assert order.cli.address == "Los Pinos, B777"
      assert order.cli.mobile_number == user_client.mobile_number

      assert order.organization_id == org.id
      assert order.org.name == org.name
      assert order.org.address == org.address
      assert order.org.mobile_number == org.mobile_number

      assert order.details |> Enum.count() == 2

      [d1, d2] = order.details
      assert d1.price == Decimal.new("30")
      assert d1.product_id == p1.id
      assert d1.variation_id == v1.id
      assert d1.name == p1.name
      assert d1.variation == v1.name
      assert d1.image_thumb == "thumb1.jpg"
      assert d1.details == "Con aji"

      assert d2.price == Decimal.new("20.5")
      assert d2.quantity == Decimal.new("2")
      assert d2.product_id == p2.id
      assert d2.variation_id == v2.id
      assert d2.name == p2.name
      assert d2.variation == v2.name

      assert %Order.Log{} = order.log

      assert %Order.Chat{} = order.chat
    end

    test "OK num" do
      org = insert(:organization, open: true)
      user_client = insert(:user_client)
      Repo.insert(%Order{user_client_id: user_client.id, organization_id: org.id})

      [p1, p2] = create_products2(org)
      v1 = Enum.at(p1.variations, 1)
      v2 = Enum.at(p2.variations, 0)

      params = %{"user_client_id" => user_client.id, "organization_id" => org.id, "currency" => org.currency,
      "client_pos" => %{"coordinates" => [-100, 30], "type" => "Point"},
      "cli" => %{"address" => "Los Pinos, B777"} ,"other_details" => "cambio de 200",
      "details" => %{
          "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
          "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
        },
        "trans" => %{"calculated_price" => "3", "ctype" => "delivery"}
      }

      {:ok, order} =  Order.create(params, user_client)

      assert order.num == 2
      assert order.organization.name == "Publit"
      assert order.inserted_at
    end

    test "transport ctype" do
      org = insert(:organization, open: true)
      user_client = insert(:user_client)
      [p1, p2] = create_products2(org)
      v1 = Enum.at(p1.variations, 1)
      v2 = Enum.at(p2.variations, 0)

      params = %{"user_client_id" => user_client.id, "organization_id" => org.id, "currency" => org.currency,
      "client_pos" => %{"coordinates" => [-100, 30], "type" => "Point"},
      "client_name" => user_client.full_name, "organization_name" => org.name,
      "client_address" => "", "other_details" => "cambio de 200",
      "details" => %{
          "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1", "image_thumb" => "thumb1.jpg"},
          "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2", "image_thumb" => "thumb2.jpg"}
        },
        "trans" => %{"calculated_price" => "5", "ctype" => "pickup"}
      }

      {:ok, order} =  Order.create(params, user_client)
      assert order.trans.ctype == "pickup"

      params = Map.put(params, "trans", %{"calculated_price" => "5", "ctype" => "nonono"})

      {:error, cs} =  Order.create(params, user_client)
      assert cs.changes.trans.errors[:ctype]
    end

    test "open org" do
      org = insert(:organization, open: false)
      user_client = insert(:user_client)
      [p1, p2] = create_products2(org)
      v1 = Enum.at(p1.variations, 1)
      v2 = Enum.at(p2.variations, 0)

      params = %{"user_client_id" => user_client.id, "organization_id" => org.id, "currency" => org.currency,
      "client_pos" => %{"coordinates" => [-100, 30], "type" => "Point"},
      "client_name" => user_client.full_name, "organization_name" => org.name,
      "client_address" => "", "other_details" => "cambio de 200",
      "details" => %{
          "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1", "image_thumb" => "thumb1.jpg"},
          "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2", "image_thumb" => "thumb2.jpg"}
        },
        "trans" => %{"calculated_price" => "5", "ctype" => "pickup"}
      }

      assert {:error, cs} =  Order.create(params, user_client)

      assert cs.errors[:organization]
    end

    test "ERROR" do
      {user, org} = create_user_org(%{})
      [p1, p2] = create_products2(org)
      v1 = Enum.at(p1.variations, 1)
      v2 = Enum.at(p2.variations, 0)

      params = %{"user_id" => user.id, "organization_id" => org.id, "currency" => org.currency,
      "client_pos" => Geo.WKT.decode("POINT(30 -90)"),
      "client_name" => "Fake name", "organization_name" => org.name,
      "address" => "Los Pinos, B777","other_details" => "cambio de 200",
      "details" => %{
          "0" => %{"product_id" => Ecto.UUID.generate, "variation_id" => v1.id, "quantity" => "1"},
          "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
        },
      "transport" => %{"calculated_price" => "5", "transport_type" => "deliver"}
      }

      assert {:error, cs} = Order.create(params, user)
      det = cs.changes.details |> Enum.at(0)
      assert det.errors[:product_id]

      params = %{"user_id" => user.id, "organization_id" => org.id, "currency" => org.currency,
      "pos" => Geo.WKT.decode("POINT(30 -90)"),
      "address" => "Los Pinos, B777","other_details" => "cambio de 200",
      "details" => %{
          "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
          "1" => %{"product_id" => p2.id, "variation_id" => Ecto.UUID.generate(), "quantity" => "2"}
        },
      "transport" => %{"calculated_price" => "5", "transport_type" => "deliver"}
      }

      assert {:error, cs} = Order.create(params, user)
      det = cs.changes.details |> Enum.at(1)
      assert det.errors[:product_id]
    end

  end

end
