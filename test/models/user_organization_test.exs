defmodule Publit.UserOrganizationTest do
  use Publit.ModelCase, async: false

  alias Publit.{UserOrganization}

  @org_attrs %{currency: "USD", name: "Home", tenant: "Publit", name: "Publit"}

  describe "add" do
    test "OK" do
      user = insert(:user)
      org = insert(:organization)

      assert Enum.count(user.organizations) == 0

      {:ok, user} = UserOrganization.add(user, org, %{"role" => "admin"})

      assert Enum.count(user.organizations) == 1
      user_org = List.first(user.organizations)

      assert user_org.organization_id == org.id
      assert user_org.name == org.name
      assert user_org.active == true
    end

    test "ERROR" do
      user = insert(:user)
      org = insert(:organization)

      assert Enum.count(user.organizations) == 0

      {:error, cs} = UserOrganization.add(user, org, %{"role" => "jeje"})

      assert cs.valid? == false
      org = cs.changes.organizations |> List.first

      assert org.errors[:role]
    end
  end

  describe "update" do
    test "OK" do
      user = insert(:user)
      org = insert(:organization)
      org2 = insert(:organization, name: "Organization 2")

      {:ok, user} = UserOrganization.add(user, org)
      user_org = List.first(user.organizations)

      assert user_org.organization_id == org.id
      assert user_org.name == org.name
      assert user_org.role == "user"
      assert user_org.active == true

      {:ok, user} = UserOrganization.add(user, org2, %{"role" => "admin"})

      assert Enum.count(user.organizations) == 2

      {:ok, user} = UserOrganization.update(user, org, %{name: "A new name", role: "admin", active: false})

      user_org = List.first(user.organizations)

      assert user_org.organization_id == org.id
      assert user_org.name == "A new name"
      assert user_org.role == "admin"
      assert user_org.active == false

      u_org = List.last(user.organizations)
      assert u_org.organization_id == org2.id
      assert u_org.role == "admin"
    end

    test "ERROR" do
      user = insert(:user)
      org = insert(:organization)

      {:error, user} = UserOrganization.update(user, org, %{name: "A new name", role: "admin", active: false})

      assert user.organizations == []
    end
  end

end
