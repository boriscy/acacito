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
    IO.inspect data
    broadcast! socket, "new_msg", %{body: data}
    {:noreply, socket}
  end

  def broadcast_order(order) do
    order = Publit.ClientApi.OrderView.to_api(order)
    Publit.Endpoint.broadcast("users:" <> order.user_client_id, "order:updated", order)
  end

  def broadcast_je(data) do
    uc = Publit.Repo.get_by(Publit.UserClient, email: "amaru@mail.com")
    Publit.Endpoint.broadcast("users:" <> uc.id, "je", data)
  end
end
