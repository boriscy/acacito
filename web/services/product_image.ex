defmodule Publit.ProductImage do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:big, :thumb]
  @extension_whitelist ~w(.jpg .jpeg)

  def transform(:big, _), do: {:convert, "-strip -thumbnail 500x500"}
  def transform(:thumb, _), do: {:convert, "-strip -thumbnail 100x100"}

  def __versions, do: [:big, :thumb]
  def public_dir(), do: "uploads"
  def storage_dir(_, _), do: "priv/static/#{public_dir()}"
  def __storage, do: Arc.Storage.Local
  def filename(:big, {file, _}), do: "big-#{Path.basename(file.file_name)}"
  def filename(:thumb, {file, _}), do: "thumb-#{Path.basename(file.file_name)}"

  def img_url(:big, product), do: "#{public_dir()}/#{filename(:big, {product.image, nil})}"
  def img_url(:thumb, product), do: "#{public_dir()}/#{filename(:thumb, {product.image, nil})}"

end
