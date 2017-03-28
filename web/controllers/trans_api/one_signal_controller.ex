defmodule Publit.TransApi.OneSignalController do
  use Publit.Web, :controller
  plug :scrub_params, "login" when action in [:create]
  alias Publit.{UserTransport}


  # PUT /trans_api/open_signal/:user_id
  def update(conn, %{"player_id" => player_id}) do
    user = conn.assigns.current_user_transport

    case UserTransport.update_os_player_id(user, player_id) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

end
