defmodule Publit.OrganizationTest do
  use Publit.ModelCase

  alias Publit.{Organization}

  @valid_attrs %{currency: "USD", name: "Home",  settings: %{theme: "dark"},
    info: %{address: "Samaipata", mobile: "73732677", age: 40, valid: true, list: [%{a: 1}, %{a: "String"}] }
  }
  @invalid_attrs %{}

  describe "create" do
    test "OK" do
      {:ok, org} = Organization.create(@valid_attrs)

      assert org.id
      assert org.name == "Home"
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
    end
  end

  describe "update" do
    test "OK" do
      org = insert(:organization, currency: "USD")
      assert org.currency == "USD"

      {:ok, org} = Organization.update(org, %{name: "Changes to name", currency: "BOB", address: "The other address"})

      assert org.name == "Changes to name"
      assert org.address == "The other address"
      assert org.currency == "USD"
    end

    test "OK geom" do
      org = insert(:organization, currency: "USD")
      p = Geo.WKT.decode("POINT(30 -90)")
      {:ok, org} = Organization.update(org, %{name: "Changes to name", geom: p})

      assert org.geom
    end
  end

end
