defmodule Publit.ProductView do
  use Publit.Web, :view

  def img_url(version, product) do
    Publit.ProductImage.img_url(version, product)
  end
end
