defmodule Publit.Api.SessionView do
  use Publit.Web, :view

  def render("login.json", _params) do
    %{message: gettext("You need to login")}
  end
end
