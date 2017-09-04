defmodule PublitWeb.UserChannel do
  use Phoenix.Channel

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
    order = PublitWeb.ClientApi.OrderView.to_api(order)
    PublitWeb.Endpoint.broadcast("users:" <> order.user_client_id, status, order)
  end

  def broadcast_position(user, status \\ "position") do
    u_pos = PublitWeb.TransApi.PositionView.encode_user_pos(user)
    PublitWeb.Endpoint.broadcast("users:" <> user.id, status, u_pos)
  end

end
