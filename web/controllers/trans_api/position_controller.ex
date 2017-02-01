defmodule Publit.TransApi.PositionController do
  use Publit.Web, :controller
  plug :scrub_params, "position"

  # POST /trans_api/position
  def position(conn, %{"position" => position}) do
IO.inspect position
    text(conn, "Hola position")
  end

  @doc """
  Tracks the position of an order
  """
  # POST /trans_api/order_position
  def position(conn, %{"position" => position}) do
    text(conn, "Hola position")
  end
end
