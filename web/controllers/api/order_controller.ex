defmodule Publit.Api.OrderController do
  use Publit.Web, :controller
  plug :scrub_params, "order" when action in [:create]
  alias Publit.{Order}


  # GET /api/orders
  def index(conn, _params) do
    user_id = conn.assigns.current_user.id

    render(conn, "index.json", orders: Order.user_orders(user_id))
  end

  # GET /api/orders/:id
  def show(conn, %{"id" => id}) do
    case (Repo.get(Order, id) |> Repo.preload(:organization)) do
      nil ->
        render_not_found(conn)
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

  # PUT /api/orders/:id/move_next
  def move_next(conn, %{"id" => id}) do
    case Repo.get(Order, id) do
      nil -> render_not_found(conn)
      order ->
        case Order.next_status(order, conn.assigns.current_user.id) do
          {:ok, order} ->
            render(conn, "show_org.json", order: order)
        end
    end
  end

  defp render_not_found(conn, args \\ %{msg: gettext("Could not find the order")}) do
    conn
    |> put_status(:not_found)
    |> render("not_found.json", msg: args.msg)
  end

end
