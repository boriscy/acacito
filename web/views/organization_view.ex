defmodule Publit.OrganizationView do
  use Publit.Web, :view

  def render("show.json", %{organization: organization}) do
    %{organization: organization}
  end


  def render("error.json", %{errors: errors}) do
    %{errors: errors}
  end

  def show_point(point) do
    case point do
      nil -> ""
      p ->
        {lat, lng} = p.coordinates

        "Lat: #{lat}, Lon: #{lng}"
    end
  end

  def to_api(org) do
    org = org
    |> Map.drop([:__meta__, :__struct__, :settings, :products])

    if org.pos do
      org |> Map.put(:pos, Geo.JSON.encode(org.pos))
    else
      org
    end
  end
end
