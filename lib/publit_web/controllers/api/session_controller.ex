defmodule PublitWeb.Api.SessionController do
  use PublitWeb, :controller
  alias Publit.{UserUtil}

  # POST /api/validate_token
  def validate_token(conn, %{"phone" => phone, "message" => msg}) do
IO.inspect phone
IO.inspect msg
    case UserUtil.check_mobile_verification_token(phone, msg) do
    {:ok, user} ->
      render(conn, "show.json", user: user)
    :error ->
      conn
      |> put_status(:unprocessable_entity)
      |> render("error.json", msg: "Invalid")
    end
  end

end
