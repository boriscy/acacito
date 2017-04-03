defmodule Publit.OrderView do
  use Publit.Web, :view

  def to_api(order) do
    order
    |> Map.drop([:__meta__, :__struct__, :user_client, :user_transport, :organization, :chat, :log, :order_calls])
    |> Map.put(:client_pos, Geo.JSON.encode(order.client_pos))
    |> Map.put(:organization_pos, Geo.JSON.encode(order.organization_pos))
    |> Map.merge(%{user_client: %{}, user_transport: %{}, organization: %{}, chat: [], log: [], order_calls: [] })
  end
end
