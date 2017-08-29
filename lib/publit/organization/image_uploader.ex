defmodule Publit.Organization.ImageUploader do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:big, :thumb]
  @acl :public_read
  @extension_whitelist ~w(.jpg .jpeg)

  def transform(:big, _), do: {:convert, "-strip -thumbnail 500x500"}
  def transform(:thumb, _), do: {:convert, "-strip -thumbnail 200x200"}

  def filename(version, _) do
    version
  end

  def storage_dir(_, {_, org}) do
    "organizations/#{org.id}"
  end

  def s3_object_headers(version, {file, scope}) do
    [content_type: Plug.MIME.path(file.file_name)] # for "image.png", would produce: "image/png"
  end

  @s3 Application.get_env(:ex_aws, :s3)
  @bucket Application.get_env(:arc, :bucket)

  def path(org, :big), do: s3_url(org, :big)
  def path(org, :thumb), do: s3_url(org, :thumb)
  defp s3_url(org, version) do
    "#{@s3[:scheme]}#{@s3[:host]}/#{@bucket}/organizations/#{org.id}/#{version}#{Path.extname(org.image.file_name)}"
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

  defp slugify(name) do
    name = String.downcase(name)
    name = Regex.replace(~r/\s/, name, "_")
    Regex.replace(~r/[^a-z0-9]/, name, "_")
  end
end

