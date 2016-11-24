defmodule Publit.OrderTest do
  use Publit.ModelCase
  import Publit.Support.Session, only: [create_user_org: 1]

  alias Publit.{Order, ProductVariation}

  @valid_attrs %{details: %{}, location: "some content", total: "120.5", user_id: "7488a646-e31f-11e4-aace-600308960662"}
  @invalid_attrs %{}

  defp create_products(org) do
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
      [p1, p2] = create_products(org)
      v1 = Enum.at(p1.variations, 1)
      v2 = Enum.at(p2.variations, 0)

      params = %{"user_id" => user.id, "organization_id" => org.id,
      "location" => Geo.WKT.decode("POINT(30 -90)"),
      "details" => %{
          "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
          "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
        }
      }

      {:ok, order} =  Order.create(params)

      assert order.number == 1

      assert order.total == Decimal.new("71.0")

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

      [p1, p2] = create_products(org)
      v1 = Enum.at(p1.variations, 1)
      v2 = Enum.at(p2.variations, 0)

      params = %{"user_id" => user.id, "organization_id" => org.id,
      "location" => Geo.WKT.decode("POINT(30 -90)"),
      "details" => %{
          "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
          "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
        }
      }

      {:ok, order} =  Order.create(params)

      assert order.number == 2
    end
  end
end
