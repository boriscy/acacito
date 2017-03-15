defmodule Publit.ClientApi.ProductView do
  use Publit.Web, :view

  def render("products.json", %{products: products}) do
    products = products |> Enum.map(&to_api/1)

    %{products: products}
  end

  def to_api(prod) do
    Map.drop(prod, [:__meta__, :organization])
    |> Map.put(:image, Publit.ProductView.img_url(prod, :big))
    |> Map.delete(:extra_info)
  end

  def get_image(prod) do
    if prod.image do
      Publit.ProductImage.img_url(:big, prod)
    else
      nil
    end
  end
end
