defmodule PublitWeb.DashboardController do
  use PublitWeb, :controller

  # GET /dashboard
  def index(conn, _params) do
    render(conn, "index.html")
  end
end
