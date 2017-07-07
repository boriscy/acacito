defmodule Publit.Distance do
  #@vehicles ["walk", "bike", "motorcycle", "car", "truck"]
  defstruct [:walk, :bike, :motorcycle, :car, :truck]

  @doc """
  Calculates the prices for mutiple vehicles using the distance and the vehicle type
  """
  def calculate_price(vehicle_type) do
    case vehicle_type do
      "car" -> 10.0
      "bike" -> 10.0
      "walk" -> 10.0
    end
  end

end
