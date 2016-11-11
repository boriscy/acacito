defmodule Publit.Plug.OrganizationAuth do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  alias Publit.{Repo, Organization, Repo, Endpoint}

  def init(default), do: default

  def call(conn, _default) do
    if !conn.assigns[:current_organization] do
      case get_organization(conn) do
        {:ok, org} ->
          conn
          |> assign(:current_organization, org)
        :error ->
          conn
          |> put_flash(:error, "You need to login")
          |> clear_session()
          |> redirect(to: "/login")
          |> halt()
      end
    else
      conn
    end
  end

  defp get_organization(conn) do
    with org_token <- get_session(conn, :organization_id),
      {:ok, org_id} <- Phoenix.Token.verify(Endpoint, "organization_id", org_token),
      {:ok, org_id} <- Ecto.UUID.cast(org_id) do
        case Repo.get(Organization, org_id) do
          nil -> :error
          org -> {:ok, org}
        end
    else
      _ -> :error
    end
  end
end
