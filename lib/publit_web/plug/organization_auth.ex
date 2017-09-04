defmodule PublitWeb.Plug.OrganizationAuth do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  import PublitWeb.Gettext
  import Plug.Conn
  alias Publit.{Repo, Organization, Repo}
  def init(default), do: default
  def call(conn, _default) do
    if !conn.assigns[:current_organization] do
      case get_organization(conn) do
        {:ok, org} ->
          conn
          |> assign(:current_organization, org)
          |> assign(:current_user_org, get_user_org(conn, org))
        :error ->
          conn
          |> put_flash(:error, gettext("You need to login"))
          |> clear_session()
          |> redirect(to: "/login")
          |> halt()
      end
    else
      conn
    end
  end
  def verify_admin_user(conn, opts) do
    path = opts[:path] || "/"
    user_org = get_user_organization(conn)
    if user_org.role != "admin" do
      conn
      |> put_flash(:error, gettext("You don't have permission to access this page"))
      |> redirect(to: path)
      |> halt()
    else
      conn
    end
  end
  defp get_user_organization(conn) do
    org_id = conn.assigns.current_organization.id
    conn.assigns.current_user.organizations
    |> Enum.find(fn(uo) -> uo.organization_id == org_id end)
  end
  defp get_organization(conn) do
    with org_token <- get_session(conn, :organization_id),
      {:ok, org_id} <- Phoenix.Token.verify(PublitWeb.Endpoint, "organization_id", org_token),
      {:ok, org_id} <- Ecto.UUID.cast(org_id) do
        case Repo.get(Organization, org_id) do
          nil -> :error
          org -> {:ok, org}
        end
    else
      _ -> :error
    end
  end
  defp get_user_org(conn, org) do
    conn.assigns.current_user.organizations
    |> Enum.find(fn(uo) -> uo.organization_id == org.id end)
  end
end
