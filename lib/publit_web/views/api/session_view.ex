defmodule PublitWeb.Api.SessionView do
  use PublitWeb, :view

  def render("show.json", %{user: user}) do
    %{user: to_api(user)}
  end

  def render("error.json", %{msg: msg}) do
    %{error: msg}
  end

  def to_api(user) do
    Map.drop(user, [:__meta__, :__struct__])
  end
end
