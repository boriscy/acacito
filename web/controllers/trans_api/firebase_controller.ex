defmodule Publit.TransApi.FirebaseController do
  use Publit.Web, :controller
  plug :scrub_params, "login" when action in [:create]
  alias Publit.{UserTransport}


  # PUT /trans_api/firebase/:user_id
  def update(conn, %{"token" => token}) do
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

end
