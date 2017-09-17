defmodule PublitWeb.Api.LoginController do
  use PublitWeb, :controller
  plug :scrub_params, "login" when action in [:create]
  alias Publit.{UserAuthentication, User}

  @max_age Application.get_env(:publit, :session_max_age)


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


  # GET /api/valid_token/:token
  def valid_token(conn, %{"token" => token}) do
    case Phoenix.Token.verify(PublitWeb.Endpoint, "user_id", token, max_age: @max_age) do
      {:ok, _user_id} ->
        #user = Repo.get(User, user_id)
        render(conn, "valid_token.json", valid: true)
      {:error, :invalid} ->
        conn
        |> put_status(:unauthorized)
        |> render("valid_token.json", valid: false)
    end
  end

end
