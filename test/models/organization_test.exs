defmodule Publit.OrganizationTest do
  use Publit.ModelCase

  alias Publit.{Organization}

  @valid_attrs %{currency: "USD", name: "Home",  settings: %{theme: "dark"},
   description: "One of the finest places in Samaipata",
    mobile_number: "59173732677",
    info: %{address: "Samaipata", age: 40, valid: true, list: [%{a: 1}, %{a: "String"}] }
  }
  #@invalid_attrs %{}

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
      {:ok, org} = Organization.create(%{"name" => "A new name", "mobile_number" => "59177889911"})

      assert org.name == "A new name"
      assert org.currency == "BOB"
      assert org.open == false
    end

    test "open_close" do
      {:ok, org} = Organization.create(%{"name" => "A new name", "mobile_number" => "59177889911"})

      assert org.name == "A new name"
      assert org.currency == "BOB"
      assert org.open == false

      uid = Ecto.UUID.generate()

      {:ok, org} = Organization.open_close(org, uid)

      assert org.open == true
      assert org.info["last_opened_by"] == uid

      {:ok, org} = Organization.open_close(org, uid)

      assert org.open == false
      assert org.info["last_closed_by"] == uid
      assert org.info["last_opened_by"] == uid
    end

  end

  describe "update" do
    test "OK" do
      org = insert(:organization, currency: "USD")
      assert org.currency == "USD"

      {:ok, org} = Organization.update(org, %{
        name: "Changes to name", currency: "BOB", address: "The other address",
        mobile_number: "59177112233",
        pos: %{"coordinates" => [-63, -18], "type" => "Point"}, })

      assert org.name == "Changes to name"
      assert org.address == "The other address"
      assert org.currency == "USD"
      assert org.mobile_number == "59177112233"
    end

    test "OK pos" do
      org = insert(:organization, currency: "USD")
      p = %{"coordinates" => [-100, 30], "type" => "Point"}
      {:ok, org} = Organization.update(org, %{name: "Changes to name", pos: p})

      assert org.pos == %Geo.Point{coordinates: {-100, 30}, srid: nil}
    end

  end

end
