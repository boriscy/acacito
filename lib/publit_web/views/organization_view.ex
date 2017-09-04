defmodule PublitWeb.OrganizationView do
  use PublitWeb, :view
  alias Publit.Organization

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
    |> Map.put(:images, get_images(org))

    if org.pos do
      org |> Map.put(:pos, Geo.JSON.encode(org.pos))
    else
      org
    end
  end

  def get_images(org) do
    Enum.map(org.images, fn(img) ->
      img = Map.put(img, :organization_id, org.id)
      thumb = Organization.ImageUploader.path(img, :thumb)
      big = Organization.ImageUploader.path(img, :big)
      %{ctype: img.ctype, thumb: thumb, big: big, filename: img.filename }
    end)
  end

end
