defmodule Publit.Api.SearchController do
  use Publit.Web, :controller
  plug :scrub_params, "search"
  alias Publit.{SearchService}

  # POST /api/search
  def search(conn, %{"search" => search_params}) do
    rows = SearchService.search(search_params)
    
    render(conn, "search.json", results: rows)
  end
end
