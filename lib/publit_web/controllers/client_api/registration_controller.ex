defmodule PublitWeb.ClientApi.RegistrationController do
  use PublitWeb, :controller
  plug :scrub_params, "user" when action in [:create]
  alias Publit.{UserClient, UserAuthentication, UserUtil, Repo}


  # POST /client_api/registration
  def create(conn, %{"user" => user_params}) do
    case UserClient.create(user_params) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

  # POST /client_api/validate_token
  def validate_token(conn, %{"phone" => phone, "message" => msg}) do
    case UserClient.verify_mobile_number(phone, msg) do
    {:ok, user} ->
      render(conn, "show.json", user: user)
    :error ->
      conn
      |> put_status(:unprocessable_entity)
      |> render("error.json", msg: "Invalid")
    end
  end

end
