defmodule PublitWeb.Api.LoginView do
  use PublitWeb, :view

  def render("show.json", %{user: user, token: token}) do
    %{user: to_api(user), token: token}
  end

  def render("errors.json", %{cs: cs}) do
    %{errors: get_errors(cs)}
  end

  def render("valid_token.json", %{valid: valid}) do
    %{valid: valid}
  end

  def to_api(user) do
    user
    |> Map.take([:id, :full_name, :email, :locale, :mobile_number, :type])
  end
end
