defmodule Publit.WorkAreaController do
  use Publit.Web, :controller
  plug :put_layout, "work_area.html"

  # GET /work_area
  def index(conn, _params) do
    render(conn, "index.html")
  end
end
