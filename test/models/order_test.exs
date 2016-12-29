defmodule Publit.OrderTest do
  use Publit.ModelCase
  import Publit.Support.Session, only: [create_user_org: 1]
  #import Mock

  alias Publit.{Order, ProductVariation}

  @valid_attrs %{details: %{}, location: "some content", total: "120.5", user_id: "7488a646-e31f-11e4-aace-600308960662"}
  @invalid_attrs %{}

  defp create_order() do
    {user, org} = create_user_org(%{})
    [p1, p2] = create_products2(org)
    v1 = Enum.at(p1.variations, 1)
    v2 = Enum.at(p2.variations, 0)
    params = %{"user_id" => user.id, "organization_id" => org.id, "currency" => org.currency,
    "location" => %{"coordinates" => [-100, 30], "type" => "Point"},
    "details" => %{
        "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
        "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
      }, "transport" => %{"calculated_price" => "7"}
    }

    {:ok, order} = Order.create(params)
    order
  end
  defp create_products2(org) do
    p1 = insert(:product, organization_id: org.id, publish: true)
    p2 = insert(:product, name: "Super Salad", organization_id: org.id, publish: true,
     variations: [
      %ProductVariation{price: Decimal.new("20.5")}
    ])

    [p1, p2]
  end


  describe "create" do
    test "OK" do
      {user, org} = create_user_org(%{})
      [p1, p2] = create_products2(org)
      v1 = Enum.at(p1.variations, 1)
      v2 = Enum.at(p2.variations, 0)

      params = %{"user_id" => user.id, "organization_id" => org.id, "currency" => org.currency,
      "location" => %{"coordinates" => [-100, 30], "type" => "Point"},
      "details" => %{
          "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
          "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
        }, "transport" => %{"calculated_price" => "5"}
      }

      {:ok, order} = Order.create(params)

      assert order.location == %Geo.Point{coordinates: {-100, 30}, srid: nil}
      assert order.number == 1
      assert order.total == Decimal.new("71.0")
      assert order.currency == org.currency
      assert order.status == "new"

      assert order.details |> Enum.count() == 2

      [d1, d2] = order.details
      assert d1.price == Decimal.new("30")
      assert d1.product_id == p1.id
      assert d1.variation_id == v1.id
      assert d1.name == p1.name
      assert d1.variation == v1.name

      assert d2.price == Decimal.new("20.5")
      assert d2.quantity == Decimal.new("2")
      assert d2.product_id == p2.id
      assert d2.variation_id == v2.id
      assert d2.name == p2.name
      assert d2.variation == v2.name
    end

    test "OK number" do
      {user, org} = create_user_org(%{})
      Repo.insert(%Order{user_id: user.id, organization_id: org.id})

      [p1, p2] = create_products2(org)
      v1 = Enum.at(p1.variations, 1)
      v2 = Enum.at(p2.variations, 0)

      params = %{"user_id" => user.id, "organization_id" => org.id, "currency" => org.currency,
      "location" => %{"coordinates" => [-100, 30], "type" => "Point"},
      "details" => %{
          "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
          "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
        }, "transport" => %{"calculated_price" => "3"}
      }

      {:ok, order} =  Order.create(params)

      assert order.number == 2
      assert order.organization.name == "Publit"
    end

    test "ERROR" do
      {user, org} = create_user_org(%{})
      [p1, p2] = create_products2(org)
      v1 = Enum.at(p1.variations, 1)
      v2 = Enum.at(p2.variations, 0)

      params = %{"user_id" => user.id, "organization_id" => org.id, "currency" => org.currency,
      "location" => Geo.WKT.decode("POINT(30 -90)"),
      "details" => %{
          "0" => %{"product_id" => Ecto.UUID.generate, "variation_id" => v1.id, "quantity" => "1"},
          "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
        }
      }

      assert {:error, cs} = Order.create(params)
      det = cs.changes.details |> Enum.at(0)
      assert det.errors[:product_id]

      params = %{"user_id" => user.id, "organization_id" => org.id, "currency" => org.currency,
      "location" => Geo.WKT.decode("POINT(30 -90)"),
      "details" => %{
          "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
          "1" => %{"product_id" => p2.id, "variation_id" => Ecto.UUID.generate(), "quantity" => "2"}
        }
      }

      assert {:error, cs} = Order.create(params)
      det = cs.changes.details |> Enum.at(1)
      assert det.errors[:product_id]
    end

  end

  describe "Change status" do
    test "change to process" do
      ord = create_order()
      assert Enum.count(ord.log) == 1

      {:ok, ord} = Order.next_status(ord, Ecto.UUID.generate() )
      assert Enum.count(ord.log) == 2
      assert ord.status == "process"

      {:ok, ord} = Order.next_status(ord, Ecto.UUID.generate() )
      assert Enum.count(ord.log) == 3
      assert ord.status == "transport"
    end

    test "previous" do
      ord = create_order()
      assert Enum.count(ord.log) == 1

      {:ok, ord} = Order.next_status(ord, Ecto.UUID.generate() )
      assert Enum.count(ord.log) == 2
      assert ord.status == "process"
      log = ord.log |> List.last
      assert log[:type] == "update_next"

      {:ok, ord} = Order.previous_status(ord, Ecto.UUID.generate() )
      assert Enum.count(ord.log) == 3
      assert ord.status == "new"
      log = ord.log |> List.last
      assert log[:type] == "update_back"
    end
  end
end
