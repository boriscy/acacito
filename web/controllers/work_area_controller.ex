defmodule Publit.WorkAreaController do
  use Publit.Web, :controller
  plug :put_layout, "work_area.html"

  # GET /work_area
  def index(conn, _params) do
    token = Publit.UserAuthentication.encrypt_user_id(conn.assigns.current_user.id)
    orgtoken = Phoenix.Token.sign(Publit.Endpoint, "organization_id", conn.assigns.current_organization.id)
    render(conn, "index.html", token: token, orgtoken: orgtoken)
  end

  #
  def publish(conn, params) do
    Publit.OrganizationChannel.broadcast_data(%{id: params["id"], name: params["name"] || "JOJO"})
    text conn, "Ola"
  end
end
