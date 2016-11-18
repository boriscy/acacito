defmodule Publit.SessionController do
  use Publit.Web, :controller
  plug :scrub_params, "user_auth" when action in [:create]
  plug :put_layout, "basic.html"

  alias Publit.{UserAuth, Endpoint}

  # GET /login
  def index(conn, _params) do
    render(conn, "index.html", changeset: UserAuth.changeset(), valid: true)
  end

  # POST /login
  def create(conn, %{"user_auth" => user_auth_params}) do
    case UserAuth.valid_user(user_auth_params) do
      {:ok, user} ->
        {conn, route} = set_organization(conn, user)
        conn
        |> put_flash(:info, "Logged in correctly")
        |> put_session(:user_id, UserAuth.encrypt_user(user))
        |> redirect(to: route)
      {:error, cs} ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> put_status(:unprocessable_entity)
        |> render("index.html", changeset: cs, valid: false)
    end
  end

  defp set_organization(conn, user) do
    case Enum.find(user.organizations, &(&1.active)) do
      nil ->
        {conn, "/organizations"}
      org ->
        conn = conn
        |> put_session(:organization_id, Phoenix.Token.sign(Publit.Endpoint, "organization_id", org.organization_id))

        {conn, "/dashboard"}
    end
  end

end
