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

end
