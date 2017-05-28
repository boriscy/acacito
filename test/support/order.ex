defmodule Publit.Support.Order do
  alias Publit.{Repo, Product, Order, Order.Transport, ProductVariation}

  def create_order(user_client, org) do
    prods = create_products(org)
    p1 = Enum.at(prods, 0)
    p2 = Enum.at(prods, 1)

    v1 = Enum.at(p1.variations, 0)
    v2 = Enum.at(p2.variations, 1)

    params = %{"user_client_id" => user_client.id, "organization_id" => org.id, "currency" => org.currency,
    "client_pos" => %{"coordinates" => [-100, 30], "type" => "Point"}, "client_name" => user_client.full_name,
    "client_address" => "Los Nuevos Pinos, B100 7", "other_details" => "Cambio de 200BS.",
    "details" => %{
        "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
        "1" => %{"product_id" => p2.id, "variation_id" => v2.id, "quantity" => "2"}
      }, "transport" => %{"calculated_price" => "7"}
    }

    {:ok, order} = Order.create(params, user_client)

    order
  end

  def create_order_only(user_client, org, params \\ %{}) do
    %Geo.Point{coordinates: {lng, lat}} = org.pos
    lng = lng + 0.0001
    lat = lat + 0.0001
    {:ok, order} = Repo.insert(%Order{
      organization_id: org.id, organization_pos: org.pos, organization_name: org.name, other_details: "Another detail",
      user_client_id: user_client.id, client_pos: %Geo.Point{coordinates: {lng, lat}, srid: nil}, client_name: user_client.full_name,
      transport: %Order.Transport{calculated_price: Decimal.new("5")},
      details: [
        %{product_id: Ecto.UUID.generate(), name: "First product", price: Decimal.new("5"), quantity: Decimal.new("1")},
        %{product_id: Ecto.UUID.generate(), name: "Second product", price: Decimal.new("7.5"), quantity: Decimal.new("2")}
      ]
    } |> Map.merge(params) )

    order
  end

  def create_products(org) do
    products()
    |> Enum.map(fn(prod) -> Map.merge(prod, %{description: prod.name <> " Rico", organization_id: org.id}) end)
    |> Enum.map(fn(prod) ->
      {:ok, prod} = Repo.insert(prod)
      prod
    end)
  end

  def update_order_and_create_user_transport(ord) do
    ut = Publit.Factory.insert(:user_transport, orders: [%{"id" => ord.id, "status" => ord.status}])

    {:ok, ord} = Ecto.Changeset.change(ord)
    |> Ecto.Changeset.put_change(:user_transport_id, ut.id)
    |> Publit.Repo.update()

    {ord, ut}
  end

  defp products do
    [
      %Product{name: "Goulash", publish: true, tags: ["sopa", "vegetariano"],
        variations: [%ProductVariation{name: nil, price: Decimal.new("30")}] },

      %Product{name: "Pizza", publish: true, tags: ["pizza", "queso"],
        variations: [%ProductVariation{name: "Mini", price: Decimal.new("15")}, %ProductVariation{name: "Medio", price: Decimal.new("25")} ] },

      %Product{
        name: "Aji de fideo", publish: true, tags: ["carne", "picante", "comida boliviana", "bolivia"],
        variations: [%ProductVariation{name: nil, price: Decimal.new("30")}] }
    ]
  end

end
