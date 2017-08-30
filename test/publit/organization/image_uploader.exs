defmodule Publit.Organization.ImageUploaderTest do
  use ExUnit.Case
  alias Publit.Organization

  @bucket Application.get_env(:arc, :bucket)
  @s3 Application.get_env(:ex_aws, :s3)
  @region @s3[:region]

  test "path" do
    org_id = Ecto.UUID.generate()
    img = %Organization.Image{ctype: "list", filename: "lista.jpg", organization_id: org_id}

    assert Organization.ImageUploader.path(img, :thumb) == "https://s3-#{@region}.amazonaws.com/#{@bucket}/organizations/#{org_id}/org/list-thumb.jpg"
    assert Organization.ImageUploader.path(img, :big) == "https://s3-#{@region}.amazonaws.com/#{@bucket}/organizations/#{org_id}/org/list-big.jpg"

    img = %Organization.Image{ctype: "logo", filename: "logo.png", organization_id: org_id}

    assert Organization.ImageUploader.path(img, :thumb) == "https://s3-#{@region}.amazonaws.com/#{@bucket}/organizations/#{org_id}/org/logo-thumb.png"
    assert Organization.ImageUploader.path(img, :big) == "https://s3-#{@region}.amazonaws.com/#{@bucket}/organizations/#{org_id}/org/logo-big.png"
  end
end
