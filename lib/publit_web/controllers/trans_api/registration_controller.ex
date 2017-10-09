defmodule PublitWeb.TransApi.RegistrationController do
  use PublitWeb, :controller
  alias Publit.UserTransport
  alias PublitWeb.SharedRegistrationController

  # POST /trans_api/registration
  def create(conn, params), do: SharedRegistrationController.create(UserTransport, conn, params)

end
