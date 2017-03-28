defmodule Publit.TransApi.OneSignalView do
  use Publit.Web, :view

  def render("show.json", %{user: user}) do
    %{user: user}
  end

  def render("errors.json", %{errors: errors}) do
    %{errors: errors}
  end
end
