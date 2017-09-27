defmodule PublitWeb.TransApi.SessionController do
  use PublitWeb, :controller
  alias Publit.{Repo, UserUtil, UserTransport, SmsService}
  alias PublitWeb.ClientApi
  plug :scrub_params, "auth" when action in [:token]

  @max_age Application.get_env(:publit, :session_max_age)

  # POST /trans_api/login
  def create(conn, %{"mobile_number" => mobile_number}) do
    case UserUtil.set_mobile_verification_token(UserTransport, mobile_number) do
      {:ok, user} ->
        render(conn, ClientApi.SessionView, "show.json", user: user, sms_gateway: SmsService.sms_gateway_num())
      _ ->
        conn
        |> put_status(:not_found)
        |> render(ClientApi.SessionView, "error.json", msg: gettext("Mobile number not found"))
    end
  end

  # POST /trans_api/get_token
  def get_token(conn, %{"auth" => params}) do
    case UserUtil.valid_mobile_verification_token(UserTransport, params) do
      %{user: user, token: token} ->
        render(conn, ClientApi.SessionView, "show.json", user: user, token: token)
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ClientApi.SessionView, "error.json", msg: gettext("Invalid token"))
    end
  end
end
