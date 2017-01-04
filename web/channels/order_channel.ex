defmodule Publit.OrderChannel do
  use Publit.Web, :channel

  def join("orders:" <> order_id, _params, socket) do
    {:ok, "Joined order #{order_id}", socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end
end
