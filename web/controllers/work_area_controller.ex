defmodule Publit.OrderController do
  use Publit.Web, :controller
  plug :put_layout, "order.html"

  # GET /orders
  def index(conn, _params) do
    token = Publit.UserAuthentication.encrypt_user_id(conn.assigns.current_user.id)
    orgtoken = Phoenix.Token.sign(Publit.Endpoint, "organization_id", conn.assigns.current_organization.id)
    render(conn, "index.html", token: token, orgtoken: orgtoken)
  end

end
