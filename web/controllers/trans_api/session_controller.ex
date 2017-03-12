defmodule Publit.TransApi.SessionController do
  use Publit.Web, :controller
  plug :scrub_params, "login" when action in [:create]
  alias Publit.{UserAuthentication, UserTransport, Repo}


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

  @doc """
  Returns the validity of token and the user data
  """
  # GET /trans_api/valid_token_user/:token
  def valid_token(conn, %{"token" => token}) do
    with {:ok, user_id} <- Phoenix.Token.verify(Publit.Endpoint, "user_id", token, max_age: @max_age),
      ut <- Repo.get_by(UserTransport, id: user_id),
      %UserTransport{} <- ut do
        render(conn, "show.json", user: ut, token: token)
    else
      _ ->
        conn
        |> put_status(:unauthorized)
        |> render("valid_token.json", valid: false)
    end
  end

end
