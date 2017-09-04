defmodule PublitWeb.ClientApi.ProductView do
  use PublitWeb, :view

  def render("products.json", %{products: products}) do
    products = products |> Enum.map(&to_api/1)

    %{products: products}
  end

  def to_api(prod) do
    PublitWeb.ProductView.to_api(prod)
  end

  def get_image(prod) do
    if prod.image do
      Publit.Product.ImageUploader.path(:big, prod)
    else
      nil
    end
  end
end
