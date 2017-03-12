defmodule Publit.ClientApi.SessionController do
  use Publit.Web, :controller
  plug :scrub_params, "login" when action in [:create]
  alias Publit.{UserAuthentication, Repo, UserClient}
  @max_age Application.get_env(:publit, :session_max_age)

  # POST /client_api/login
  def create(conn, %{"login" => login_params}) do
    case UserAuthentication.valid_user_client(login_params) do
      {:ok, user} ->
        token = UserAuthentication.encrypt_user_id(user.id)
        render(conn, "show.json", user: user, token: token)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

  # GET /client_api/valid_token/:token
  def valid_token(conn, %{"token" => token}) do
    with {:ok, user_id} <- Phoenix.Token.verify(Publit.Endpoint, "user_id", token, max_age: @max_age),
      uc <- Repo.get_by(UserClient, id: user_id),
      %UserClient{} <- uc do
        render(conn, "valid_token.json", valid: true)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> render("valid_token.json", valid: false)
    end
  end

end
