defmodule Publit.Organization.ImageUploader do
  use Arc.Definition

  @versions [:big, :thumb]
  @s3 Application.get_env(:ex_aws, :s3)
  @bucket Application.get_env(:arc, :bucket)

  @acl :public_read
  @extension_whitelist ~w(.jpg .jpeg .png)

  def transform(:big, _), do: {:convert, "-strip -thumbnail 500x500"}
  def transform(:thumb, _), do: {:convert, "-strip -thumbnail 200x200"}

  def filename(version, {_file, scope}) do
    "#{scope.ctype}-#{version}"
  end

  def storage_dir(_version, {_file, img}) do
    "organizations/#{img.organization_id}/org"
  end

  def path(img, :big), do: s3_url(img, :big)
  def path(img, :thumb), do: s3_url(img, :thumb)
  def s3_url(img, version) do
    "#{main_path(img)}/#{filename(version, {nil, img})}#{Path.extname(img.filename)}"
  end
  defp main_path(img) do
    "#{@s3[:scheme]}#{@s3[:host]}/#{@bucket}/organizations/#{img.organization_id}/org"
  end

end
