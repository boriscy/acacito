defmodule Publit.ProductImage do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:big, :thumb]
  @extension_whitelist ~w(.jpg .jpeg)

  def transform(:big, _), do: {:convert, "-strip -thumbnail 500x500"}
  def transform(:thumb, _), do: {:convert, "-strip -thumbnail 200x200"}

  def __versions, do: [:big, :thumb]
  def public_dir, do: "uploads"
  def storage_dir(_, _), do: "priv/static/#{public_dir()}"
  def __storage, do: Arc.Storage.Local

  def filename(:big, {_file, prod}) do
    "#{partial_name(prod)}-big"
  end
  def filename(:thumb, {file, prod}) do
    "#{partial_name(prod)}-thumb"
  end

  def img_url(:big, product), do: img_urlp(:big, product)
  def img_url(:thumb, product), do: img_urlp(:thumb, product)
  defp img_urlp(ver, product) do
    "/#{public_dir()}/#{filename(ver, {product.image, product})}#{Path.extname(product.image.file_name)}"
  end

  @doc """
  Deletes the image for the version
  """
  def delete(ver, product) do
    if __storage() == Arc.Storage.Local do
      p = Path.join([System.cwd(), "priv/static", img_url(ver, product)])
      File.rm(p)
    else
      ""
    end
  end

  def delete_all(product) do
    Enum.each(@versions, fn(ver)->
      delete(ver, product)
    end)
  end

  defp partial_name(prod) do
    String.slice(prod.organization_id, 0, 8) <> "-" <> slugify(prod.name)
  end

  defp slugify(name) do
    name = String.downcase(name)
    name = Regex.replace(~r/\s/, name, "_")
    Regex.replace(~r/[^a-z0-9]/, name, "_")
  end
end
