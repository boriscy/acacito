defmodule Publit.PageController do
  use Publit.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
