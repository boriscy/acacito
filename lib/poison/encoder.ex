defimpl Poison.Encoder, for: Geo.Point do

  def encode(point, options) do
    {lng, lat} = point.coordinates
    Poison.Encoder.encode(%{lat: lat, lng: lng}, options)
  end
end
