defmodule PublitWeb.ClientApi.SearchController do
  use PublitWeb, :controller
  plug :scrub_params, "search"
  alias Publit.{SearchService}

  # POST /api/search
  def search(conn, %{"search" => search_params}) do
    rows = SearchService.search(search_params)
    |> Enum.map(&PublitWeb.OrganizationView.to_api/1)

    render(conn, "search.json", results: rows )
  end
end
