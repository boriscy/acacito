defmodule Publit.ProductController do
  use Publit.Web, :controller
  alias Publit.{Product}
  plug :scrub_params, "product" when action in [:create, :update]

  # GET /products
  def index(conn, _params) do
    products = Product.all(conn.assigns.current_organization.id)

    render(conn, "index.html", products: products)
  end

  # GET /products/new
  def new(conn,_params) do
    product = Product.new()

    render(conn, "new.html", product: product)
  end

  # POST /products
  def create(conn, %{"product" => product_params}) do

  end
end
