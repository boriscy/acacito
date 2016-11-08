defmodule Publit.SessionController do
  use Publit.Web, :controller
  plug :scrub_params, "user" when action in [:create]

  alias Publit.{UserAuth}

  # GET /login
  def index(conn, _params) do
    render(conn, "index.html", changeset: UserAuth.changeset())
  end

  # POST /login
  def create(conn, %{"user" => user_params}) do
    case UserAuth.valid_user(user_params) do
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
        |> render("index.html", changeset: cs)
    end
  end

  defp set_organization(conn, user) do
    case Enum.find(user.organizations, &(&1.active)) do
      nil ->
        {conn, "/organizations"}
      org ->
        conn = conn
        |> put_session(:organization_id, Phoenix.Token.sign(Publit.Endpoint, "organization_id", org.organization_id))

        {conn, "/store"}
    end
  end

end
