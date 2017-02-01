defmodule Publit.TransApi.FirebaseController do
  use Publit.Web, :controller
  plug :scrub_params, "login" when action in [:create]
  alias Publit.{UserTransport}


  # PUT /trans_api/firebase/:user_id
  def update(conn, %{"id" => _id, "token" => token}) do
    user = conn.assigns.current_user_transport

    case UserTransport.update_fb_token(user, token) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
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
