defmodule Publit.ClientApi.ProductView do
  use Publit.Web, :view

  def render("products.json", %{products: products}) do
    products = products |> Enum.map(&to_api/1)

    %{products: products}
  end

  def to_api(prod) do
    Publit.ProductView.to_api(prod)
  end

  def get_image(prod) do
    if prod.image do
      Publit.ProductImage.path(:big, prod)
    else
      nil
    end
  end
end
