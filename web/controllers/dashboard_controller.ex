defmodule Publit.DashboardController do
  use Publit.Web, :controller

  # GET /dashboard
  def index(conn, _params) do
    render(conn, "index.html")
  end
end
