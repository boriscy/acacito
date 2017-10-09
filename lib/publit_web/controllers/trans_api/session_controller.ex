defmodule PublitWeb.TransApi.SessionController do
  use PublitWeb, :controller
  alias Publit.{UserTransport}

  # POST /trans_api/login
  def create(conn, params), do: PublitWeb.SharedSessionController.create(UserTransport, conn, params)

  # POST /trans_api/get_token
  def get_token(conn, params), do: PublitWeb.SharedSessionController.get_token(UserTransport, conn, params)

  # GET /trans_api/valid_token/:token
  def valid_token(conn, params), do: PublitWeb.SharedSessionController.valid_token(conn, params)

end
