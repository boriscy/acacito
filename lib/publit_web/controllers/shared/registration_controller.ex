defmodule PublitWeb.SharedRegistrationController do
  use PublitWeb, :controller
  alias Publit.{SmsService}
  alias PublitWeb.SharedRegistrationView
  plug :scrub_params, "user" when action in [:create]

  @doc """
  Common action to create user
  """
  def create(mod, conn, %{"user" => user_params}) do
    case mod.create(user_params) do
      {:ok, user} ->
        render(conn, SharedRegistrationView, "show.json", user: user, sms_gateway: SmsService.sms_gateway_num())
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(SharedRegistrationView, "errors.json", cs: cs)
    end
  end

end

