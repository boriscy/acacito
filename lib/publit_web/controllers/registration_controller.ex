defmodule PublitWeb.RegistrationController do
  use PublitWeb, :controller
  alias Publit.{RegistrationService, UserAuthentication}

  plug :scrub_params, "registration_service" when action in [:create]
  plug :put_layout, "basic.html"

  # GET /registration
  def index(conn, _params) do
    registration = Ecto.Changeset.change(%RegistrationService{})

    render(conn, "index.html", registration: registration, valid: true)
  end

  # POST /registration
  def create(conn, %{"registration_service" => regis_params}) do
    case RegistrationService.register(regis_params) do
      {:ok, %{org: org, user: user}} ->
        conn
        |> put_session(:user_id, UserAuthentication.encrypt_user_id(user.id))
        |> put_session(:organization_id, Phoenix.Token.sign(PublitWeb.Endpoint, "organization_id", org.id))
        |> redirect(to: "/dashboard")
      {:error, registration} ->
        render(conn, "index.html", registration: registration, valid: false)
    end
  end

end
