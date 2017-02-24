defmodule Publit.TransApi.OrderView do
  use Publit.Web,:view

  def render("index.json", %{orders: orders}) do
    orders = Enum.map(orders, &to_api/1)

    %{orders: orders}
  end

  def render("not_found.json", %{}) do
    %{message: gettext("Order not found")}
  end

  def render("show.json", %{order: order}) do
    %{order: Publit.Api.OrderView.to_api2(order)}
  end

  def render("empty.json", %{}) do
    %{message: gettext("No transport available")}
  end

  def render("errors.json", %{cs: cs}) do
    errors = Map.merge(get_errors(cs), %{transport: get_errors(cs.changes.transport)})
    %{errors: errors}
  end

  def to_api(order) do
    order
    |> Map.drop([:__meta__, :__struct__, :user_client, :user_transport, :order_calls, :organization])
    |> Map.put(:client_pos, Geo.JSON.encode(order.client_pos))
    |> Map.put(:organization_pos, Geo.JSON.encode(order.organization_pos))
  end
end
