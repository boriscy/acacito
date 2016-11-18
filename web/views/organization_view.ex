defmodule Publit.OrganizationView do
  use Publit.Web, :view

  def render("show.json", %{organization: organization}) do
    %{organization: organization}
  end


  def render("error.json", %{errors: errors}) do
    %{errors: errors}
  end
end
