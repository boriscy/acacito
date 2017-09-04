defmodule PublitWeb.Api.PositionController do
  use PublitWeb, :controller
  alias Publit.{Repo, UserTransport}

  # GET /api/user_transport_position/:id
  def user_transport(conn, %{"id" => id}) do
    case user = Repo.get(UserTransport, id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{})
      user ->
        conn
        |> render(PublitWeb.TransApi.PositionView, "position.json", user: user)
    end

  end

end
