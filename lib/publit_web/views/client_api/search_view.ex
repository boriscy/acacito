defmodule PublitWeb.ClientApi.SearchView do
  use PublitWeb, :view

  def render("search.json", %{results: results}) do
    %{results: results}
  end

  def render("errors.json", %{cs: cs}) do
    %{errors: get_errors(cs)}
  end
end
