defmodule PublitWeb.OrderController do
  use PublitWeb, :controller
  plug :put_layout, "order.html"

  # GET /orders
  def index(conn, _params) do
    if valid_org?(conn.assigns.current_organization) do
      token = Publit.UserAuthentication.encrypt_user_id(conn.assigns.current_user.id)
      orgtoken = Phoenix.Token.sign(PublitWeb.Endpoint, "organization_id", conn.assigns.current_organization.id)

      render(conn, "index.html", token: token, orgtoken: orgtoken)
    else
      conn
      |> put_flash(:warning, gettext("You must set your position."))
      |> redirect(to: "/organizations/current")
    end
  end

  defp valid_org?(org) do
    case org.pos do
      %Geo.Point{coordinates: {_a, _b}, srid: _} ->
        true
      _ ->
        false
    end
  end

end
