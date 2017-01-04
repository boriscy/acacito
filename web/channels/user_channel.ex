defmodule Publit.UserChannel do
  use Publit.Web, :channel

  def join("users:" <> user_id, _params, socket) do
    {:ok, "Joined user #{user_id}", socket}
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  def broadcast_user(data) do
    Publit.Endpoint.broadcast("users:" <> data.user_id, "new:data", data)
  end
end
