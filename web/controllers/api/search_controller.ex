defmodule Publit.Api.SearchController do
  use Publit.Web, :controller
  plug :scrub_params, "search"

  # POST /api/search
  def search(conn, %{"search" => search_params}) do
    render(conn, "search.json", results: [])
  end
end
