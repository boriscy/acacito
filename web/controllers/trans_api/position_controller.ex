defmodule Publit.TransApi.PositionController do
  use Publit.Web, :controller
  plug :scrub_params, "position"
  alias Publit.{UserTransport}

  # POST /trans_api/position
  def position(conn, %{"position" => position}) do
    case UserTransport.update_position(conn.assigns.current_user_transport, position) do
      {:ok, user} ->
        render(conn, "position.json", user: user)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

  @doc """
  Tracks the position of an order
  """
  # POST /trans_api/order_position
  def position(conn, %{"position" => position}) do
    text(conn, "Hola position")
  end
end
