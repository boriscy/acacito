defmodule Publit.ClientApi.PushyController do
  use Publit.Web, :controller
  alias Publit.{UserClient}


  # PUT /client_api/pushy
  def update(conn, %{"device_token" => device_token}) do
    user = conn.assigns.current_user_client

    case UserClient.update_device_token(user, device_token) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

end
