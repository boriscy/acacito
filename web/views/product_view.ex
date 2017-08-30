defmodule Publit.ProductView do
  use Publit.Web, :view
  alias Publit.Product

  def to_api(prod) do
    Map.drop(prod, [:__meta__, :organization])
    |> Map.put(:image, img_url(prod, :big))
    |> Map.put(:image_thumb, img_url(prod, :thumb))
    |> Map.delete(:extra_info)
  end

  def img_url(product, version \\ :thumb) do
    if product.image && product.image.file_name do
      Product.ImageUploader.path(product, version)
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

  def encode_tags(cs) do
    data = if cs.changes == %{} do
      cs.data.tags
    else
      cs.changes[:tags]
    end

    Poison.encode!(data || [])
  end

  def encode_product(cs) do
    m = Map.merge(cs.data, cs.changes)
    |> Map.drop([:__struct__, :__meta__, :organization])
    |> Map.put(:image, img_url(cs.data, :big))
    if cs.valid? do
      m |> Poison.encode!()
    else
      m
      |> Map.put(:errors, Enum.into(cs.errors, %{}, fn({key, val}) -> {key, translate_error(val)} end) )
      |> Map.put(:variations, Enum.map(cs.changes.variations, fn(vari) -> encode_variation(vari)  end) )
      |> Poison.encode!()
    end
  end

  def encode_variation(cs) do
    vari = Map.merge(cs.data, cs.changes)
    |> Map.drop([:__struct__, :__meta__])

    if cs.valid? do
      vari
    else
      Map.put(vari, :errors, Enum.into(cs.errors, %{}, fn({key, val}) -> {key, translate_error(val)} end) )
    end
  end

  def all_tags(conn) do
    Publit.Product.all_tags(conn.assigns.current_organization.id)
  end

  defp variations_data(:data, variations) do
    Enum.map(variations, fn(p) -> %{id: p.id, name: p.name, price: p.price} end)
  end

  defp variations_data(:changes, variations) do
    Enum.map(variations, fn(p) ->
      Map.merge(p.data, p.changes)
      |> Map.put(:errors, get_errors(p))
    end)
  end

end
