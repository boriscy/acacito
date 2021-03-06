defmodule Publit.ProductTest do
  use Publit.ModelCase
  import Mock

  alias Publit.{Product, Organization, Repo}

  #@valid_attrs %{"name" => "Pizza", "price" => "40.5"}

  def organization do
    insert(:organization)
  end

  @variations [
    %{"price"=> "20", "name" => "Small", "description" => "Small size 10 x 10"},
    %{"price"=> "30", "name" => "Medium", "description" => "Medium size 15 x 15"},
    %{"price"=> "40", "name" => "Big", "description" => "Big size 20 x 20"}
  ]

  defp valid_attrs(org) do
    %{"name" => "Pizza", "price" => "40.5", "organization_id" => org.id,
      "tags" => ["pizza", "cheese"],
      "variations" => @variations, "description" => "This should be **strong**"}
  end

  describe "create" do
    test "OK" do
      org = organization()
      assert {:ok, product} = Product.create(valid_attrs(org))

      assert product.tags == ["pizza", "cheese"]
      assert product.description == "This should be **strong**"
      assert Enum.count(product.variations) == 3
      p1 = Enum.at(product.variations, 0)
      assert p1.description == "Small size 10 x 10"
    end

    test "ERROR" do
      assert {:error, cs} = Product.create(%{})

      assert cs.errors[:name]
      assert cs.errors[:organization_id]
    end

    test "Invalid varition" do
      org = organization()
      attrs = %{
        "name" => "Pizza", "price" => "40.5", "organization_id" => org.id,
        "variations" => [%{"price"=> "-20", "name" => "Small", "description" => "Small size 10 x 10"}]
      }

      assert {:error, cs} = Product.create(attrs)

      assert cs.changes.variations
      pv = Enum.at(cs.changes.variations, 0)

      assert pv.errors[:price]
    end

    test_with_mock "image", Product.ImageUploader, [],
      [store: fn({img, upl}) -> {:ok, img.filename } end] do

      org = insert :organization
      attrs = Map.put(valid_attrs(org), "image", %Plug.Upload{filename: "prod1.jpg"})
      assert {:ok, product} = Product.create(attrs)

      assert %{file_name: "prod1.jpg"} = product.image
    end
  end

  describe "update" do
    test "OK" do
      org = insert :organization, images: [%Organization.Image{filename: "uno.jpg", ctype: "list"}]
      assert {:ok, product} = Product.create(valid_attrs(org))

      [pv1, pv2, pv3] = product.variations
      attrs = %{
        "name" => "A new name", "organization_id" => org.id,
        "tags" => %{"0" => "multiple", "1" => "other"}, "description" => "A new *italic* text",
        "published" => "true",
        "variations" =>
        [%{"price"=> "22", "name" => "Small", "description" => "Small size 10 x 10", "id" => pv1.id},
         %{"price"=> "30.5", "name" => "Medium Esp", "description" => "Medium size 15 x 15", "id" => pv2.id},
         %{"price"=> "40", "name" => "Big", "description" => "Big size 20 x 20", "id" => pv3.id}]
      }

      assert {:ok, p2} = Product.update(product, attrs)

      assert p2.name == "A new name"
      assert p2.tags == ["multiple", "other"]
      assert p2.description == "A new *italic* text"

      assert p2.organization_id == org.id

      vars = p2.variations

      assert Enum.count(vars) == 3

      pvar1 = Enum.at(vars, 0)
      assert pvar1.id == pv1.id
      assert pvar1.name == "Small"
      assert pvar1.price == Decimal.new("22")
      pv2 = Enum.at(vars, 1)
      assert pv2.name == "Medium Esp"
      assert pv2.price == Decimal.new("30.5")

      org = Repo.get(Organization, p2.organization_id)

      assert org.tags == [%{"count" => 1, "tag" => "producto"},
        %{"count" => 1, "tag" => "other"},
        %{"count" => 1, "tag" => "multiple"}]
    end
  end

end
