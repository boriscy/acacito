defmodule Publit.Api.TransportView do
  use Publit.Web, :view

  def render("show.json", %{order_call: order_call}) do
    %{order_call: to_api(order_call)}
  end

  def render("not_found.json", %{}) do
    %{message: gettext("Order not found")}
  end

  def render("errors.json",%{cs: cs}) do
    %{errors: get_errors(cs)}
  end

  def render("order.json", %{order: order}) do
    %{order: Publit.Api.OrderView.to_api(order)}
  end

  def to_api(oc) do
    Map.drop(oc, [:__struct__, :__meta__, :order])
  end
end
