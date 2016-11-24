defmodule Publit.Api.OrderView do
  def render("index.json", %{orders: orders}) do
    %{orders: orders}
  end

  def render("show.json", %{order: order}) do
    %{order: order}
  end
end
