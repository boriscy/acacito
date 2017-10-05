defmodule PublitWeb.SharedSessionController do
  use PublitWeb, :controller
  alias Publit.{UserUtil, SmsService}
  alias PublitWeb.SharedSessionView
  plug :scrub_params, "auth" when action in [:token]

  @doc """
  """
  # @type create(term, Plug.Conn.t, map) :: Plug.Conn.t
  def create(mod, conn, %{"mobile_number" => mobile_number}) do
    case UserUtil.set_mobile_verification_token(mod, to_string(mobile_number)) do
      {:ok, user} ->
        render(conn, SharedSessionView, "show.json", user: user, sms_gateway: SmsService.sms_gateway_num())
      _ ->
        conn
        |> put_status(:not_found)
        |> render(SharedSessionView, "error.json", msg: gettext("Mobile number not found"))
    end
  end

  @doc """
  Common function used in controllers to get_token for UserClient, UserTransport
  """
  def get_token(mod, conn, %{"auth" => params}) do
    case UserUtil.valid_mobile_verification_token(mod, params) do
      %{user: user, token: token} ->
        render(conn, SharedSessionView, "show.json", user: user, token: token)
      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SharedSessionView, "error.json", msg: gettext("Invalid token"))
    end
  end
end
