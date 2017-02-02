defmodule Publit.TransApi.PositionController do
  use Publit.Web, :controller
  plug :scrub_params, "position" when action in [:update_position, :order_position]
  plug :scrub_params, "status" when action in [:update_status]
  alias Publit.{UserTransport}

  @doc """
  Updates position and/or status
  """
  # PUT /trans_api/position
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
  # PUT /trans_api/order_position
  def order_position(conn, %{"position" => position}) do
    text(conn, "Hola position")
  end

  # PUT /trans_api/stop_tracking
  def stop_tracking(conn, _params) do
    case UserTransport.stop_tracking(conn.assigns.current_user_transport) do
      {:ok, user} ->
        render(conn, "position.json", user: user)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end
end
