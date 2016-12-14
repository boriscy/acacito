defmodule Publit.Api.LoginController do
  use Publit.Web, :controller
  plug :scrub_params, "login" when action in [:create]
  alias Publit.{UserAuthentication}


  # POST /api/login
  def create(conn, %{"login" => login_params}) do
    case UserAuthentication.valid_user(login_params) do
      {:ok, user} ->
        token = UserAuthentication.encrypt_user_id(user.id)
        render(conn, "show.json", user: user, token: token)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

end
