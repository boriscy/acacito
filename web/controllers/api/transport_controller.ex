defmodule Api.TransportController do
  use Publit.Web, :controller
  alias Publit.{OrderCall}

  # POST /api/transport
  # Creates a call to transports
  def create(conn, %{"order_id" => order_id}) do
  end

end
