defmodule Publit.OrganizationTest do
  use Publit.ModelCase

  alias Publit.{Organization}

  @valid_attrs %{currency: "USD", name: "Home",  settings: %{theme: "dark"},
   description: "One of the finest places in Samaipata",
    info: %{address: "Samaipata", mobile: "73732677", age: 40, valid: true, list: [%{a: 1}, %{a: "String"}] }
  }
  @invalid_attrs %{}

  describe "create" do
    test "OK" do
      {:ok, org} = Organization.create(@valid_attrs)

      assert org.id
      assert org.name == "Home"
      assert org.description == "One of the finest places in Samaipata"
    end

    test "ERROR" do
      {:error, cs} = Organization.create(%{currency: "NO"})

      assert cs.valid? == false
      assert cs.errors[:name]
      assert cs.errors[:currency]
    end

    test "OK with default" do
      {:ok, org} = Organization.create(%{"name" => "A new name"})

      assert org.name == "A new name"
      assert org.currency == "BOB"
      assert org.open == false
    end

  end

  describe "update" do
    test "OK" do
      org = insert(:organization, currency: "USD")
      assert org.currency == "USD"

      {:ok, org} = Organization.update(org, %{name: "Changes to name", currency: "BOB", address: "The other address",
        geom: %{"coordinates" => [-63, -18], "type" => "Point"}})

      assert org.name == "Changes to name"
      assert org.address == "The other address"
      assert org.currency == "USD"
    end

    test "OK geom" do
      org = insert(:organization, currency: "USD")
      p = %{"coordinates" => [-100, 30], "type" => "Point"}
      {:ok, org} = Organization.update(org, %{name: "Changes to name", geom: p})

      assert org.geom == %Geo.Point{coordinates: {-100, 30}, srid: nil}
    end

    #test "tags" do
    #  attrs = @valid_attrs
    #  org = insert(:organization, currency: "USD")
    #  tags = [%{text: "vegan", count: 3}, %{text: "vegetarian", count: 5}]
    #  {:ok, org} = Organization.update(org, %{"tags" => tags})

    #  assert org.tags == [%{text: "vegan"}]
    #end
  end

  test "to_api" do
    org = %Organization{
      name: "Org 1",
      address: "Near here",
      category: "cat 1",
      currency: "ABC",
      geom: %Geo.Point{coordinates: {-17.8145819, -63.1560853}, srid: nil}
    }

    assert Organization.to_api(org) == %{
      name: "Org 1",
      address: "Near here",
      category: "cat 1",
      currency: "ABC",
      pos: %{"coordinates" => [-17.8145819, -63.1560853], "type" => "Point"}
    }
  end

end
