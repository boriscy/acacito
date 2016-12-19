defmodule Publit.Api.ProductView do
  use Publit.Web, :view

  def render("products.json", %{products: products}) do
    products = products |> Enum.map(&to_api/1)

    %{products: products}
  end

  def to_api(prod) do
    Map.drop(prod, [:__meta__, :organization])
  end
end
