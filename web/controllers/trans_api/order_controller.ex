defmodule Publit.TransApi.OrderController do
  use Publit.Web, :controller
  alias Publit.{Order, OrderCallService}

  # GET
  def index(conn, %{"status" => status}) do
    ut_id = conn.assigns.current_user_transport.id
    orders = Order.transport_orders(ut_id, get_status(status))

    render(conn, "index.json", orders: orders)
  end

  # PUT
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
