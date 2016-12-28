defmodule Publit.Api.OrderController do
  use Publit.Web, :controller
  plug :scrub_params, "order" when action in [:create]
  alias Publit.{Order}

  # GET /api/orders
  def index(conn, _params) do
    org_id = conn.assigns.current_organization.id
    render(conn, "index.json", orders: Order.active(org_id))
  end

  # GET /api/orders/:id
  def show(conn, %{"id" => id}) do
    render(conn, "show.json", order: %{id: id, total: 12.3, name: "test"})
  end

  # POST /api/orders
  def create(conn, %{"order" => order_params}) do
    order_params = order_params |> Map.put("user_id", conn.assigns.current_user.id)
    case Order.create(order_params) do
      {:ok, order} ->
        Publit.OrganizationChannel.broadcast_order(order)
        render(conn, "show.json", order: Order.to_api(order))
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

end
