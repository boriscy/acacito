defmodule Publit.ProductView do
  use Publit.Web, :view

  def img_url(version, product) do
    if product.image do
      Publit.ProductImage.img_url(version, product)
    else
      "/images/blank.jpg"
    end
  end

  def published(product, opts \\ [fs: "fs50p"]) do
    if product.publish do
      content_tag(:span, gettext("Published"), class: "label label-success #{opts[:fs]}")
    else
      content_tag(:span, gettext("Unpublished"), class: "label label-danger #{opts[:fs]}")
    end
  end

  def publish_button(product) do
    if product.publish do
      content_tag(:button, gettext("Unpublish"), class: "btn btn-danger publish-button")
    else
      content_tag(:button, gettext("Publish"), class: "btn btn-success publish-button")
    end
  end

  def encode_variations(cs) do
    data = if cs.changes == %{} do
      variations_data(:data, cs.data.variations)
    else
      variations_data(:changes, cs.changes.variations)
    end

    Poison.encode!(data)
  end

  defp variations_data(:data, variations) do
    Enum.map(variations, fn(p) -> %{id: p.id, name: p.name, price: p.price} end)
  end

  def encode_tags(cs) do
    data = if cs.changes == %{} do
      cs.data.tags
    else
      cs.changes.tags
    end

    Poison.encode!(data)
  end

  def all_tags(conn) do
    Publit.Product.all_tags(conn.assigns.current_organization.id)
  end

  defp variations_data(:changes, variations) do
    Enum.map(variations, fn(p) ->
      Map.merge(p.data, p.changes)
      |> Map.put(:errors, get_errors(p))
    end)
  end

end
