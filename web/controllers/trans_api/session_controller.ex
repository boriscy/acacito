defmodule Publit.TransApi.SessionController do
  use Publit.Web, :controller
  plug :scrub_params, "login" when action in [:create]
  alias Publit.{UserAuthentication}


  # POST /trans_api/login
  def create(conn, %{"login" => login_params}) do
    case UserAuthentication.valid_user_transport(login_params) do
      {:ok, user} ->
        token = UserAuthentication.encrypt_user_id(user.id)
        render(conn, "show.json", user: user, token: token)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

  # GET /trans_api/valid_token/:token
  def valid_token(conn, %{"token" => token}) do
    case Phoenix.Token.verify(Publit.Endpoint, "user_id", token) do
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
