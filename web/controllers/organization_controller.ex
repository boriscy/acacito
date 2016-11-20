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

  def show(conn, %{"id" => id}) do
    #user_org = conn.assigns.current_user.organizations
    #|> Enum.find(fn(uo)-> uo.active && uo.organization_id == id end)

    #case user_org do
    #  nil -> redirect(conn, to: "/organizations")
    #  user_org ->
    #    org = Repo.get(Organization, user_org.organization_id)
    render(conn, "show.html", organization: conn.assigns.current_organization,
                              user_org: conn.assigns.current_user_org)
    #end
  end

  # PUT /organizations/xyz
  #def update(conn, %{"organization" => %{"geom" => geom}}) do
  def update(conn, %{"organization" => org_params, "format" => "json"}) do
    org_params = set_org_params(org_params)
    case Organization.update(conn.assigns.current_organization, org_params) do
      {:ok, org} ->
        conn
        |> render("show.json", organization: Organization.to_api(org))
      {:error, org} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", errors: [])
    end
  end

  # PUT /organizations/xyz
  def update(conn, %{"organization" => organization_params}) do
    case Organization.update(conn.assigns.current_organization, organization_params) do
      {:ok, org} ->
        conn
        |> redirect(to: organization_path(conn, :show, org))
      {:error, cs} ->
        conn
        |> render("edit.html", changeset: cs)
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

  defp set_org_params(params) do
    if params["geom"] && params["geom"]["lat"] && params["geom"]["lng"] do
      geom = params["geom"]
      %{params | "geom" => %Geo.Point{ coordinates: {geom["lat"], geom["lng"]}, srid: nil} }
    else
      params
    end
  end
end
