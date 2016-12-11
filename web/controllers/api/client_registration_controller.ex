defmodule Publit.Api.ClientRegistrationController do
  use Publit.Web, :controller
  plug :scrub_params, "user" when action in [:create]
  alias Publit.{UserClient, UserAuthentication}


  # POST /api/client_registration
  def create(conn, %{"user" => user_params}) do
    case UserClient.create(user_params) do
      {:ok, user} ->
        render(conn, "show.json", user: user, token: UserAuthentication.encrypt_user_id(user.id))
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

end
