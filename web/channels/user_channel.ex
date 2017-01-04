defmodule Publit.UserChannel do
  use Publit.Web, :channel

  def join("users:" <> user_id, _params, socket) do
    {:ok, "Joined user #{user_id}", socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  def broadcast_order(order) do
    order = Publit.Api.OrderView.to_api(order)
    Publit.Endpoint.broadcast("users:" <> order.user_id, "order:updated", order)
  end
end
