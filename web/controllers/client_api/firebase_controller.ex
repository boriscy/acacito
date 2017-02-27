defmodule Publit.ClientApi.FirebaseController do
  use Publit.Web, :controller
  alias Publit.{UserClient}


  # PUT /client_api/firebase/:user_id
  def update(conn, %{"token" => token}) do
    user = conn.assigns.current_user_client

    case UserClient.update_fb_token(user, token) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

end

