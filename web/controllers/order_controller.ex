defmodule Publit.OrderController do
  use Publit.Web, :controller
  plug :put_layout, "order.html"

  # GET /operations
  def index(conn, _params) do
    render(conn, "index.html")
  end
end
