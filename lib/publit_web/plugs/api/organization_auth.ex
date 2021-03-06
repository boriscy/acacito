defmodule PublitWeb.Plug.Api.OrganizationAuth do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2, render: 3]
  alias Publit.{Repo, Organization}

  @max_age Application.get_env :publit, :session_max_age

  def init(default), do: default

  def call(conn, _default) do
    if !conn.assigns[:current_organization] do
      case get_organization(conn) do
        {:ok, org} ->
          conn
          |> assign(:current_organization, org)
        :error ->
          conn
          |> put_status(:unauthorized)
          |> render(PublitWeb.Api.SessionView, "login.json")
          |> halt()
      end
    else
      conn
    end
  end

  defp get_organization(conn) do
    with [user_token] <- get_req_header(conn, "orgtoken"),
      {:ok, organization_id} <- Phoenix.Token.verify(PublitWeb.Endpoint, "organization_id", user_token, max_age: @max_age),
      {:ok, organization_id} <- Ecto.UUID.cast(organization_id),
      org <- Repo.get(Organization, organization_id),
      false <- is_nil(org) do
        {:ok, org}
    else
      _ -> :error
    end
  end

  defp salt, do: Application.get_env(:publit, PublitWeb.Endpoint)[:secret_key_base]
end
