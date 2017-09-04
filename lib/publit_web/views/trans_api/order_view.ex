defmodule PublitWeb.TransApi.OrderView do
  use PublitWeb,:view

  def render("index.json", %{orders: orders}) do
    orders = Enum.map(orders, &to_api/1)

    %{orders: orders}
  end

  def render("not_found.json", %{}) do
    %{message: gettext("Order not found")}
  end

  def render("show.json", %{order: order}) do
    %{order: PublitWeb.Api.OrderView.to_api(order)}
  end

  def render("empty.json", %{}) do
    %{message: gettext("No transport available")}
  end

  def render("errors.json", %{cs: cs}) do
    errors = Map.merge(get_errors(cs), %{trans: get_errors(cs.changes.trans)})
    %{errors: errors}
  end

  def to_api(order) do
    PublitWeb.OrderView.to_api(order)
  end
end
