defmodule Publit.ClientApi.OneSignalController do
  use Publit.Web, :controller
  alias Publit.{UserClient}


  # PUT /client_api/one_signal/:user_id
  def update(conn, %{"player_id" => player_id}) do
    user = conn.assigns.current_user_client

    case UserClient.update_os_player_id(user, player_id) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

end

