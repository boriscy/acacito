defmodule Publit.Api.OrderController do
  use Publit.Web, :controller
  plug :scrub_params, "order" when action in [:create]
  alias Publit.{Order}

  # GET /api/orders
  def index(conn, _params) do
    org_id = conn.assigns.current_organization.id
    render(conn, "index.json", orders: Order.active(org_id))
  end

  # GET /api/user_orders
  def user_orders(conn, %{"user_id" => user_id}) do
    render(conn, "orders.json", orders: Order.user_orders(user_id))
  end

  # GET /api/orders/:id
  def show(conn, %{"id" => id}) do
    case (Repo.get(Order, id) |> Repo.preload(:organization)) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("not_found.json", msg: gettext("Could not find the order"))
      order ->
        render(conn, "show.json", order: order)
    end
  end

  # POST /api/orders
  def create(conn, %{"order" => order_params}) do
    order_params = order_params |> Map.put("user_id", conn.assigns.current_user.id)
    case Order.create(order_params) do
      {:ok, order} ->
        Publit.OrganizationChannel.broadcast_order(order)
        render(conn, "show.json", order: order)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

end
