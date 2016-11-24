defmodule Publit.Api.OrderController do
  use Publit.Web, :controller

  # GET /api/orders
  def index(conn, _params) do
    render(conn, "index.json", orders: [%{total: 12.3, name: "test"}])
  end

  # GET /api/orders/id
  def show(conn, %{"id" => id}) do
    render(conn, "show.json", order: %{id: id, total: 12.3, name: "test"})
  end
end
