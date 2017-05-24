defmodule Publit.UserChannel do
  use Publit.Web, :channel

  def join("users:" <> user_id, _params, socket) do
    {:ok, "Joined user #{user_id}", socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  def handle_in("order:update", data, socket) do
    broadcast! socket, "new_msg", %{body: data}
    {:noreply, socket}
  end

  def broadcast_order(order, status \\ "order:updated") do
    order = Publit.ClientApi.OrderView.to_api(order)
    Publit.Endpoint.broadcast("users:" <> order.user_client_id, status, order)
  end

  def broadcast_position(user, status \\ "position") do
    u_pos = Publit.TransApi.PositionView.encode_user_pos(user)
    Publit.Endpoint.broadcast("users:" <> user.id, status, u_pos)
  end

end
