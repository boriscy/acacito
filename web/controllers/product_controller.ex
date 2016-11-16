defmodule Publit.ProductController do
  use Publit.Web, :controller
  alias Publit.{Product, ProductImage}
  plug :scrub_params, "product" when action in [:create, :update]
  plug :set_product when action in [:edit, :update, :delete]

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
        conn
        |> put_flash(:success, gettext("Product created."))
        |> redirect(to: product_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, gettext("There are errors in the product."))
        |> put_status(:unprocessable_entity)
        |> render("new.html", changeset: changeset, valid: false)
    end
  end

  # GET /products/:id/edit
  def edit(conn, _params) do
    changeset = Ecto.Changeset.change(conn.assigns.product)

    render(conn, "edit.html", changeset: changeset, product: conn.assigns.product, valid: true)
  end

  # PATCH /products/:id
  def update(conn, %{"product" => product_params}) do
    product_params = product_params
    |> Map.put("variations", get_product_variations(product_params))

    case Product.update(conn.assigns.product, product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:success, gettext("Product updated."))
        |> redirect(to: product_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, gettext("There are errors in the product."))
        |> put_status(:unprocessable_entity)
        |> render("edit.html", changeset: changeset, valid: false)
    end
  end

  def delete(conn, %{"id" => _id}) do
    if conn.assigns.product.publish do
      conn
      |> put_flash(:error, "Can't delete product that is published.")
      |> redirect(to: product_path(conn, :index))
    else
      Repo.delete(conn.assigns.product)
      conn
      |> put_flash(:success, gettext("Product was deleted."))
      |> redirect(to: product_path(conn, :index))
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
