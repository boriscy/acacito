defmodule Publit.Product.VariationTest do
  use Publit.ModelCase

  alias Publit.{Product}

  describe "schema" do
    test "OK" do
      pvc = Product.Variation.changeset(%Product.Variation{}, %{"price"=> "20", "name" => "Medium", "description" => "Medium size 15 x 15"})

      assert pvc.valid?
      assert pvc.changes == %{price: Decimal.new("20"), name: "Medium", description: "Medium size 15 x 15"}
    end

    test "Error" do
      pvc = Product.Variation.changeset(%Product.Variation{}, %{"price"=> "-1", "name" => "", "description" => "Medium size 15 x 15"})

      refute pvc.valid?
      refute pvc.errors[:name]
      assert pvc.errors[:price]
    end
  end

  describe "add" do
    test "OK" do
      p = Ecto.Changeset.change(%Product{})
      variations = [
        %{"price"=> "20", "name" => "Small", "description" => "Small size 10 x 10"},
        %{"price"=> "20", "name" => "Medium", "description" => "Medium size 15 x 15"},
        %{"price"=> "20", "name" => "Big", "description" => "Big size 20 x 20"}
      ]

      p = Product.Variation.add(p, variations)

      assert Enum.count(p.changes.variations) == 3
    end

  end


end
