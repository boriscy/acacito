defmodule PublitWeb.ClientApi.SessionController do
  use PublitWeb, :controller
  alias Publit.{UserClient}

  # POST /client_api/login
  def create(conn, params), do: PublitWeb.SharedSessionController.create(UserClient, conn, params)

  # POST /client_api/get_token
  def get_token(conn, params), do: PublitWeb.SharedSessionController.get_token(UserClient, conn, params)

end
