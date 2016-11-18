defmodule Publit.HomeController do
  use Publit.Web, :controller
  plug :put_layout, "basic.html"

  # GET /
  def index(conn, _params) do
    render(conn, "index.html")
  end
end
