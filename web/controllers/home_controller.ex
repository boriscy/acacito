defmodule Publit.HomeController do
  use Publit.Web, :controller

  # GET /
  def index(conn, _params) do
    render(conn, "index.html")
  end
end
