defmodule PublitWeb.ClientApi.ProductController do
  use PublitWeb, :controller
  alias Publit.{Product}

  # GET /client_api/:organization_id/products
  def products(conn, %{"organization_id" => org_id}) do
    render(conn, "products.json", products: Product.published(org_id))
  end

end
