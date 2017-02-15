defmodule Publit.TransApi.OrderView do
  use Publit.Web,:view

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

end
