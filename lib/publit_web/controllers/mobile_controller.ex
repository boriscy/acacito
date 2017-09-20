defmodule PublitWeb.MobileController do
  use PublitWeb, :controller

  # POST /dashboard
  def create(conn, params) do
    IO.inspect params

    text(conn, Poison.encode!(%{payload: %{success: true}}))
  end
end

