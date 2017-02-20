defmodule Publit.Api.OrderController do
  use Publit.Web, :controller
  alias Publit.{Order, Repo, UserChannel}

  # GET /api/org_orders
  def index(conn, _params) do
    org_id = conn.assigns.current_organization.id
    orders = Order.active(org_id) |> Repo.preload(:order_calls)

    render(conn, "index.json", orders: orders)
  end

  # GET /api/org_order/:id
  def show(conn, %{"id" => id}) do
    case (get_order(conn, id)) do
      nil ->
        render_not_found(conn)
      order ->
        render(conn, "show.json", order: order)
    end
  end

  # PUT /api/org_orders/:id/move_next
  def move_next(conn, %{"id" => id}) do
    with ord <- get_order(conn, id),
      false <- is_nil(ord) do
        user_id = conn.assigns.current_user.id

        case Order.next_status(ord, user_id) do
          {:ok, order} ->
            UserChannel.broadcast_order(order)
            render(conn, "show.json", order: order)
          _ ->
            render(conn, "error.json")
        end
    else
      _ ->
        render_not_found(conn)
    end
  end

  defp render_not_found(conn, args \\ %{msg: gettext("Could not find the order")}) do
    conn
    |> put_status(:not_found)
    |> render("not_found.json", msg: args.msg)
  end

  defp get_order(conn, id) do
    org_id = conn.assigns.current_organization.id

    Repo.get_by(Order, id: id, organization_id: org_id) |> Repo.preload(:user_client)
  end
end
