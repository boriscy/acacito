defmodule Publit.ProductImage do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:big, :thumb]
  @acl :public_read
  @extension_whitelist ~w(.jpg .jpeg)

  def transform(:big, _), do: {:convert, "-strip -thumbnail 500x500"}
  def transform(:thumb, _), do: {:convert, "-strip -thumbnail 200x200"}


  #def __versions, do: @versions
  #def public_dir, do: "uploads"
  #def storage_dir(_, _), do: "priv/static/#{public_dir()}"
  #def __storage, do: Arc.Storage.Local

  #def filename(:big, {_file, prod}) do
  #  "#{partial_name(prod)}-big"
  #end
  #def filename(:thumb, {file, prod}) do
  #  "#{partial_name(prod)}-thumb"
  #end

  #def img_url(:big, product), do: img_urlp(:big, product)
  #def img_url(:thumb, product), do: img_urlp(:thumb, product)
  #defp img_urlp(ver, product) do
  #  "/#{public_dir()}/#{filename(ver, {product.image, product})}#{Path.extname(product.image.file_name)}"
  #end

  def filename(version, _) do
    version
  end

  def storage_dir(_, {_, prod}) do
    "products/#{prod.id}"
  end

  def s3_object_headers(version, {file, scope}) do
    [content_type: Plug.MIME.path(file.file_name)] # for "image.png", would produce: "image/png"
  end

  @s3 Application.get_env(:ex_aws, :s3)
  @bucket Application.get_env(:arc, :bucket)

  def path(p, :big), do: s3_url(p, :big)
  def path(p, :thumb), do: s3_url(p, :thumb)
  defp s3_url(p, version) do
    "#{@s3[:scheme]}#{@s3[:host]}/#{@bucket}/products/#{p.id}/#{version}#{Path.extname(p.image.file_name)}"
  end

  @doc """
  Deletes the image for the version
  """
  #def delete(ver, product) do
  #  if __storage() == Arc.Storage.Local do
  #    p = Path.join([System.cwd(), "priv/static", img_url(ver, product)])
  #    File.rm(p)
  #  else
  #    ""
  #  end
  #end

  #def delete_all(product) do
  #  Enum.each(@versions, fn(ver)->
  #    delete(ver, product)
  #  end)
  #end

  #defp partial_name(prod) do
  #  String.slice(prod.organization_id, 0, 8) <> "-" <> slugify(prod.name)
  #end

  defp slugify(name) do
    name = String.downcase(name)
    name = Regex.replace(~r/\s/, name, "_")
    Regex.replace(~r/[^a-z0-9]/, name, "_")
  end
end
