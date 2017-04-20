defmodule Publit.ClientApi.RegistrationView do
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

  def render("invalid_number.json", %{msg: msg}) do
    %{msg: msg}
  end

  def render("not_found.json", %{msg: msg}) do
    %{error: msg}
  end

  def to_api(user) do
    user
    |> Map.take([:id, :full_name, :email, :locale, :mobile_number, :type])
  end
end
