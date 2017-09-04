defmodule PublitWeb.OrderView do
  use PublitWeb, :view

  def to_api(order) do
    order
    |> Map.drop([:__meta__, :__struct__, :user_client, :user_transport, :organization, :chat, :log, :order_calls])
    |> Map.put(:client_pos, Geo.JSON.encode(order.client_pos))
    |> Map.put(:organization_pos, Geo.JSON.encode(order.organization_pos))
    |> Map.put(:cli, drop_struct(order.cli))
    |> Map.put(:org, drop_struct(order.org))
    |> Map.put(:trans, drop_struct(order.trans))
    |> Map.merge(%{user_client: %{}, user_transport: %{}, organization: %{}, chat: [], log: [], order_calls: [] })
  end

  def drop_struct(st) do
    Map.drop(st, [:__meta__, :__struct__])
  end
end
