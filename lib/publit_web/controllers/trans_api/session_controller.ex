defmodule PublitWeb.TransApi.SessionController do
  use PublitWeb, :controller
  alias Publit.{UserTransport}

  # POST /client_api/login
  def create(conn, params), do: PublitWeb.SharedSessionController.create(UserTransport, conn, params)

  # POST /client_api/get_token
  def get_token(conn, params), do: PublitWeb.SharedSessionController.get_token(UserTransport, conn, params)
end
