defmodule Publit.Support.Org do
  @moduledoc """
  Module to create organization and products for an organization
  """
  alias Publit.{Repo, Product, ProductVariation}

  def create_products(org) do
    products
    |> Enum.map(fn(prod) -> Map.merge(prod, %{description: prod.name <> " Rico", organization_id: org.id}) end)
    |> Enum.map(fn(prod) ->
      {:ok, prod} = Repo.insert(prod)
      prod
    end)
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
