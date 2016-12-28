defmodule Publit.OrganizationChannel do
  use Publit.Web, :channel

  def join("organizations:" <> organization_id, payload, socket) do
    {:ok, "Joined org #{organization_id}", socket}
  end

  def handle_in({:after_join, msg}, socket) do
    broadcast!(socket, "user:entered", msg["user"])
    push socket, "join", %{status: "connected"}
    {:noreply, socket}
  end

  def handle_in("move:next", %{"order" => order}, socket) do
    broadcast!(socket, "move:next", %{order: order})
    {:noreply, socket}
  end

  def handle_out(event, payload, socket) do
    IO.inspect payload
    push socket, event, payload
    {:noreply, socket}
  end

  def broadcast_order(order) do
    ord = Publit.Api.OrderView.encode_with_user(order)
    Publit.Endpoint.broadcast("organizations:" <> order.organization_id, "new:order", ord)
  end

end
