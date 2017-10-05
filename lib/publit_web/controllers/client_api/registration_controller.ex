defmodule PublitWeb.ClientApi.RegistrationController do
  use PublitWeb, :controller
  alias Publit.UserClient
  alias PublitWeb.SharedRegistrationController

  # POST /client_api/registration
  def create(conn, params), do: SharedRegistrationController.create(UserClient, conn, params)

end
