defmodule Publit.ClientApi.PushyView do
  use Publit.Web, :view

  def render("show.json", %{user: user}) do
    %{user: to_api(user)}
  end

  def render("errors.json", %{errors: errors}) do
    %{errors: errors}
  end

  def to_api(user) do
    user
    |> Map.drop([:__meta__, :__module__])
  end
end

