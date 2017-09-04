defmodule PublitWeb.TransApi.DeviceView do
  use PublitWeb, :view

  def render("show.json", %{user: user}) do
    %{user: user}
  end

  def render("errors.json", %{errors: errors}) do
    %{errors: errors}
  end
end
