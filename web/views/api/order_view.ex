defmodule Publit.Api.OrderView do
  use Publit.Web, :view
  #import Publit.ErrorHelpers, only: [get_errors: 1]

  def render("index.json", %{orders: orders}) do
    %{orders: orders}
  end

  def render("show.json", %{order: order}) do
    %{order: order}
  end

  def render("errors.json", %{cs: cs}) do
    %{errors: get_errors(cs)}
  end
end
