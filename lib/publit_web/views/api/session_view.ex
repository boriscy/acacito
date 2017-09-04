defmodule PublitWeb.Api.SessionView do
  use PublitWeb, :view

  def render("login.json", _params) do
    %{message: gettext("You need to login")}
  end
end
