defmodule Publit.ProductController do
  use Publit.Web, :controller
  alias Publit.{Product, ProductImage}
  plug :scrub_params, "product" when action in [:create, :update]
  plug :set_product when action in [:edit, :update]

  # GET /products
  def index(conn, _params) do
    products = Product.all(conn.assigns.current_organization.id)

    render(conn, "index.html", products: products)
  end

  # GET /products/new
  def new(conn,_params) do
    changeset = Product.new()

    render(conn, "new.html", changeset: changeset, valid: true)
  end

  # POST /products
  def create(conn, %{"product" => product_params}) do
    product_params = product_params
    |> Map.put("organization_id", conn.assigns.current_organization.id)
    |> Map.put("variations", get_product_variations(product_params))

    case Product.create(product_params) do
      {:ok, product} ->
        redirect(conn, to: product_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset, valid: false)
    end
  end

  # GET /products/:id/edit
  def edit(conn, _params) do
    changeset = Ecto.Changeset.change(conn.assigns.product)

    render(conn, "edit.html", changeset: changeset, product: conn.assigns.product, valid: true)
  end

  # PATCH /products/:id
  def update(conn, %{"product" => product_params}) do
    case Product.update(conn.assigns.product, product_params) do
      {:ok, product} ->
        redirect(conn, to: product_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", changeset: changeset, valid: false)
    end
  end

  defp set_product(conn, _) do
    prod = Repo.get_by(Product, id: conn.params["id"], organization_id: conn.assigns.current_organization.id)

    conn = assign(conn, :product, prod)
  end

  defp get_product_variations(params) do
    if params["variations"] && is_map(params["variations"]) do
      Enum.map(params["variations"], fn({k, pv}) -> pv end)
    else
      []
    end
  end
end
