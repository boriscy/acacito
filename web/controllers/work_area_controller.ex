defmodule Publit.WorkAreaController do
  use Publit.Web, :controller
  plug :put_layout, "work_area.html"

  # GET /work_area
  def index(conn, _params) do
    token = Publit.UserAuthentication.encrypt_user_id(conn.assigns.current_user.id)
    render(conn, "index.html", token: token)
  end

  #
  def publish(conn, _params) do
    org = Publit.Repo.get_by(Publit.Organization, name: "Tierra Libre")
    Publit.OrganizationChannel.bc(org)
    text conn, "Ola"
  end
end
