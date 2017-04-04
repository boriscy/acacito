defmodule Publit.TransApi.DeviceController do
  use Publit.Web, :controller
  plug :scrub_params, "login" when action in [:create]
  alias Publit.{UserTransport}


  # PUT /trans_api/device/:user_id
  def update(conn, %{"device_token" => device_token}) do
    user = conn.assigns.current_user_transport

    case UserTransport.update_device_token(user, device_token) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

end
