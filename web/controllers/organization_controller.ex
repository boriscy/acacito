defmodule Publit.OrganizationController do
  use Publit.Web, :controller
  # function imported on web.ex and created in Publit.Plug.OrganizationAuth
  plug :verify_admin_user, [path: "/organizations"] when action in [:update]
  plug :scrub_params, "organization" when action in [:update]
  import Ecto.Query
  alias Publit.{Repo, Organization}


  # GET /organizations
  def index(conn, _params) do
    render(conn, "index.html", organizations: active_organizations(conn.assigns.current_user))
  end

  # PUT /organizations/xyz
  def update(conn, %{"organization" => %{"geom" => geom}}) do
    geom = %Geo.Point{ coordinates: {geom["lat"], geom["lng"]}, srid: nil}
    case Organization.update(conn.assigns.current_organization, %{"geom" => geom}) do
      {:ok, org} ->
        conn
        |> render("show.json", organization: Organization.to_api(org))
      {:error, org} ->
        conn
        |> render("error.json", errors: [])
    end
  end

  # PUT /organizations/xyz
  def update(conn, %{"organization" => organization_params}) do
    case Organization.update(conn.assigns.current_organization, organization_params) do
      {:ok, org} ->
        conn
        |> render("show.html")
      {:error, org} ->
        conn
        |> render("edit.html")
    end
  end

  defp active_organizations(user) do
    with u_orgs <- Enum.filter(user.organizations, &(&1.active)),
      ids <- u_orgs |> Enum.map(&(&1.organization_id)) do
        q = from(o in Organization, where: o.id in ^ids)
        Repo.all(q)
    else
      _ ->
        []
    end
  end
end
