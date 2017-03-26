defmodule Publit.OrganizationView do
  use Publit.Web, :view

  def render("show.json", %{organization: organization}) do
    %{organization: to_api(organization)}
  end

  def render("error.json", %{cs: cs}) do
    %{errors: get_errors(cs)}
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
