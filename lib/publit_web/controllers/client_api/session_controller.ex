defmodule PublitWeb.ClientApi.SessionController do
  use PublitWeb, :controller
  plug :scrub_params, "login" when action in [:create]
  alias Publit.{UserAuthentication, Repo, UserClient}

  @max_age Application.get_env(:publit, :session_max_age)

  # POST /client_api/login
  def create(conn, %{"login" => login_params}) do
    case UserUtil.set_mobile_verification_token(UserClient, login_params) do
      {:ok, uc} ->
        render(conn, "show.json", user: uc)
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", msg: gettext("Phone not found"))
    end

  end

  # GET /client_api/valid_token/:token
  def valid_token(conn, %{"token" => token}) do
    with {:ok, user_id} <- Phoenix.Token.verify(PublitWeb.Endpoint, "user_id", token, max_age: @max_age),
      uc <- Repo.get_by(UserClient, id: user_id),
      %UserClient{} <- uc do
        token = UserAuthentication.get_new_token(user_id, token)

        render(conn, "show.json", user: uc, token: token)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> render("valid_token.json", valid: false)
    end
  end

end
