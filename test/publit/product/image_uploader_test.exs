defmodule Publit.Product.ImageUploaderTest do
  use ExUnit.Case
  alias Publit.Product

  test "path" do
    p = %Product{image: %{file_name: "prod.jpg"}, organization_id: "76709434-bc00-44f2-9d22-45a340c326a7", id: "5dd1253e-c03a-48dc-9ac6-6dfb559fd627"}

    assert Product.ImageUploader.path(p, :thumb) == "https://s3-sa-east-1.amazonaws.com/acacitotest/organizations/76709434-bc00-44f2-9d22-45a340c326a7/products/5dd1253e-c03a-48dc-9ac6-6dfb559fd627/thumb.jpg"
    assert Product.ImageUploader.path(p, :big) == "https://s3-sa-east-1.amazonaws.com/acacitotest/organizations/76709434-bc00-44f2-9d22-45a340c326a7/products/5dd1253e-c03a-48dc-9ac6-6dfb559fd627/big.jpg"
  end

end
