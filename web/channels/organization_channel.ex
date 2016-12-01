defmodule Publit.OrganizationChannel do
  use Publit.Web, :channel

  def join("organizations:" <> organization_id, _params, socket) do
    {:ok, socket}
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
end
