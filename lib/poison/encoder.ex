defimpl Poison.Encoder, for: Geo.Point do

  def encode(point, options) do
    Geo.JSON.encode(point) |> Poison.Encoder.encode(options)
  end
end
