defmodule Publit.Api.ProductController do
  use Publit.Web, :controller
  alias Publit.{Product}

  # GET /api/:organization_id/products
  def products(conn, %{"organization_id" => org_id}) do
    render(conn, "products.json", products: Product.published(org_id))
  end

end
