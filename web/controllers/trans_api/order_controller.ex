defmodule Publit.TransApi.OrderController do
  use Publit.Web, :controller
  alias Publit.{Order, OrderCallService}

  # GET /trans_api/orders
  def index(conn, _params) do
    ut_id = conn.assigns.current_user_transport.id
    orders = Order.transport_orders(ut_id, ["transport", "transporting"])

    render(conn, "index.json", orders: orders)
  end

  # PUT /trans_api/accept/:order_id
  def accept(conn, %{"order_id" => order_id}) do
    ut = conn.assigns.current_user_transport

    case Repo.get(Order, order_id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("not_found.json")
      order ->
        case OrderCallService.accept(order, ut, get_accept_params(order)) do
          :empty ->
            conn |> put_status(:precondition_failed) |> render("empty.json")
          {:error, :order, cs} ->
            conn |> put_status(:unprocessable_entity) |> render("errors.json", cs: cs)
          {:ok, order, _pid} ->
            Publit.OrganizationChannel.broadcast_order(order, "order:updated")
            render(conn, "show.json", order: order)
        end
    end
  end

  # PUT /trans_api/deliver/:order_id
  def deliver(conn, %{"order_id" => order_id}) do
    case Repo.get_by(Order, id: order_id, status: "transporting") do
      nil ->
        conn
        |> put_status(:not_found)
        |> render("not_found.json", msg: "Order not found")
      order ->
        case OrderStatusService.move_next(order, conn.assigns.current_user_transport) do
          {:ok, ut} ->
            render(conn, "show.json", ut: ut)
        end
    end
  end

  defp get_accept_params(order) do
    %{final_price: order.transport.calculated_price}
  end

  defp get_status(status) do
    cond do
      is_list(status) ->
        status
      is_map(status) ->
        Enum.into(status, [], fn({key, val}) -> val end)
      true ->
        []
    end
  end

end
