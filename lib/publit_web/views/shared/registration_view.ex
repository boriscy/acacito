defmodule PublitWeb.SharedRegistrationView do
  use PublitWeb, :view

  def render("show.json", %{user: user, sms_gateway: sms_gateway}) do
    %{user: to_api(user), sms_gateway: sms_gateway}
  end

  def render("errors.json", %{cs: cs}) do
    %{errors: get_errors(cs)}
  end

  def render("valid_token.json", %{valid: valid}) do
    %{valid: valid}
  end

  def to_api(user) do
    user
    |> Map.drop([:__meta__, :__struct__])
  end
end

