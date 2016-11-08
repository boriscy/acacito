defmodule Publit.OrganizationTest do
  use Publit.ModelCase

  alias Publit.{Organization, User, Repo}

  @valid_attrs %{currency: "USD", name: "Home", tenant: "Publit",
    settings: %{show_search_on_focus: true, theme: "dark"},
    info: %{address: "Samaipata", mobile: "73732677", age: 40, valid: true, list: [%{a: 1}, %{a: "String"}] }
  }
  @invalid_attrs %{}


  test "Store json data" do
    changeset = Organization.changeset(%Organization{}, @valid_attrs)
    {:ok, org} = Repo.insert(changeset)

    assert @valid_attrs.name == org.name
    assert @valid_attrs.settings.theme == org.settings.theme
    assert @valid_attrs.info.address == org.info.address
  end

  test "Invalid currency" do
    changeset = Organization.changeset(%Organization{}, Map.merge(@valid_attrs, %{currency: "JU"}))

    refute changeset.valid?
    errors = Publit.ListHelper.errors_map(changeset.errors)

    assert errors.currency == "is invalid"
  end

  test "empty info" do
    new_vals = Map.delete(@valid_attrs, :info)
    changeset = Organization.changeset(%Organization{}, new_vals)
    {:ok, org} = Repo.insert(changeset)

    #IO.inspect org.id
    assert org.info == %{}
  end

  test "empty settings" do
    changeset = Organization.changeset(%Organization{})

    org_set = changeset.changes.settings.data

    assert org_set.theme == "Publit"
    assert org_set.show_search_on_focus == true
  end

  test "validation" do
    changeset =  Organization.changeset(%Organization{}, %{})
    assert changeset.valid? == false
  end

  ######################################################
  # Create organization with user
  @user_attrs %{email: "amaru@mail.com", password: "demo1234", full_name: "Amaru Barroso", last_name: "some content", settings: %{}}
  test "creation" do
    user = User.changeset(%User{}, @user_attrs)
    user = Repo.insert!(user)

    assert Enum.count(user.organizations) == 0

    {:ok, org} = Organization.create(user, %{"name" => "Publit", "currency" => "USD"})

    assert org.name == "Publit"
    assert org.info.created_by == user.id

    user = Repo.get_by(User, id: user.id)
    assert Enum.count(user.organizations) == 1
    user_org = List.first(user.organizations)

    assert user_org.active == true
    assert user_org.tenant == "Publit"
    assert user_org.role == "admin"
    assert user_org.name == "Publit"
  end

end
