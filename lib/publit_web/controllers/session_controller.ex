defmodule PublitWeb.SessionController do
  use PublitWeb, :controller
  plug :scrub_params, "user_authentication" when action in [:create]
  plug :put_layout, "basic.html"

  alias Publit.{UserAuthentication}

  # GET /login
  def index(conn, _params) do
    render(conn, "index.html", changeset: UserAuthentication.changeset(), valid: true)
  end

  # POST /login
  def create(conn, %{"user_authentication" => user_auth_params}) do
    case UserAuthentication.valid_user(user_auth_params) do
      {:ok, user} ->
        {conn, route} = set_organization(conn, user)
        conn
        |> put_flash(:info, gettext("Logged in correctly"))
        |> put_session(:user_id, UserAuthentication.encrypt_user_id(user.id))
        |> redirect(to: route)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("index.html", changeset: cs, valid: false)
    end
  end

  # DELETE /logout
  def delete(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> redirect(to: "/login")
  end

  defp set_organization(conn, user) do
    case Enum.find(user.organizations, &(&1.active)) do
      nil ->
        {conn, "/organizations"}
      org ->
        conn = conn
        |> put_session(:organization_id, Phoenix.Token.sign(PublitWeb.Endpoint, "organization_id", org.organization_id))

        {conn, "/dashboard"}
    end
  end

end
