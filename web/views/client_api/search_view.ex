defmodule Publit.ClientApi.SearchView do
  use Publit.Web, :view
  #import Publit.ErrorHelpers, only: [get_errors: 1]

  def render("search.json", %{results: results}) do
    %{results: results}
  end

  def render("errors.json", %{cs: cs}) do
    %{errors: get_errors(cs)}
  end
end
