defmodule PublitWeb.ClientApi.SessionController do
  use PublitWeb, :controller
  alias Publit.{Repo, UserUtil, UserClient}


  plug :scrub_params, "auth" when action in [:token]

  @max_age Application.get_env(:publit, :session_max_age)

  # POST /client_api/login
  def create(conn, %{"mobile_number" => mobile_number}) do
    case UserUtil.set_mobile_verification_token(UserClient, mobile_number) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      _ ->
        conn
        |> put_status(:not_found)
        |> render("error.json", msg: gettext("Mobile number not found"))
    end
  end

  # POST /client_api/get_token
  def get_token(conn, %{"auth" => params}) do
    case UserUtil.valid_mobile_verification_token(UserClient, params) do
      %{user: user, token: token} ->
        render(conn, "show.json", user: user, token: token)
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("error.json", msg: gettext("Invalid token"))
    end
  end

end
