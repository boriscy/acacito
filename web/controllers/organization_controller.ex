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

  # GET /organizations/:id
  def show(conn, _params) do
    render(conn, "show.html", organization: conn.assigns.current_organization,
                              user_org: conn.assigns.current_user_org)
  end

  # GET /organizations/:id/edit
  def edit(conn, _params) do
    render(conn, "edit.html", organization: conn.assigns.current_organization,
                              user_org: conn.assigns.current_user_org)
  end

  # PUT /organizations/current
  # render json
  def update(conn, %{"organization" => org_params, "format" => "json"}) do
    case Organization.update(conn.assigns.current_organization, org_params) do
      {:ok, org} ->
        conn
        |> render("show.json", organization: org)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", cs: cs)
    end
  end

  # PUT /organizations/current
  def update(conn, %{"organization" => organization_params}) do
    case Organization.update(conn.assigns.current_organization, organization_params) do
      {:ok, org} ->
        conn
        |> redirect(to: organization_path(conn, :show, org))
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("edit.html", changeset: cs)
    end
  end

  # PUT /organizations/open_close
  def open_close(conn, _params) do
    user_id = conn.assigns.current_user.id

    case Organization.open_close(conn.assigns.current_organization, user_id) do
      {:ok, org} ->
        render(conn, "show.json", organization: org)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", cs: cs)
    end
  end

  # List of the current user active organizations
  defp active_organizations(user) do
    with u_orgs <- Enum.filter(user.organizations, &(&1.active)),
      ids <- u_orgs |> Enum.map(&(&1.organization_id)),
      true <- is_list(ids) do
        q = from(o in Organization, where: o.id in ^ids)
        Repo.all(q)
    else
      _ ->
        []
    end
  end

end
