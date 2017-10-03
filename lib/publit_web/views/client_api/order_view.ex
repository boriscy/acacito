defmodule PublitWeb.ClientApi.OrderView do
  use PublitWeb, :view

  def render("index.json", %{orders: orders}) do
    orders = Enum.map(orders, &to_api/1)

    %{orders: orders}
  end

  def render("show.json", %{order: order}) do
    %{order: to_api(order)}
  end

  def render("errors.json", %{cs: cs}) do
    %{errors: get_errors(cs)}
  end

  def render("not_found.json", %{msg: msg}) do
    %{error: msg}
  end

  def to_api(order) do
    PublitWeb.OrderView.to_api(order)
  end

end
