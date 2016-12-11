defmodule Publit.Api.ClientRegistrationView do
  use Publit.Web, :view

  def render("show.json", %{user: user, token: token}) do
    %{user: to_api(user), token: token}
  end

  def render("show.json", %{user: user}) do
    %{user: to_api(user)}
  end


  def render("errors.json", %{cs: cs}) do
    %{errors: get_errors(cs)}
  end

  def to_api(user) do
    user
    |> Map.take([:id, :full_name, :email, :locale, :mobile_number, :type])
  end
end
