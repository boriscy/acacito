defmodule Publit.RegistrationServiceTest do
  use Publit.ModelCase
  alias Publit.RegistrationService

  @valid_attrs %{email: "amaru@mail.com", password: "demo1234",
                 name: "La Pizzeria", category: "restaurant",
                 mobile_number: "59177889900",
                 address: "Samaipata, frente al Jaguar Azul"}

  describe "register" do
    test "OK" do
      resp = RegistrationService.register(@valid_attrs)

      assert {:ok, %{org: org, user: user}} = resp
      assert user.id
      assert org.id

      user_org = Enum.find(user.organizations, fn(o) -> o.active && o.organization_id == org.id end)

      assert user_org.organization_id == org.id
      assert user_org.active == true
      assert user_org.role == "admin"
      assert user.encrypted_password
    end

    test "taken email" do
      resp = RegistrationService.register(@valid_attrs)

      assert {:ok, %{org: org, user: user}} = resp

      {:error, :user, user, _b} = RegistrationService.register(@valid_attrs)

      assert user.errors[:email] == {"has already been taken", []}
    end

    test "take mobile_number" do
      resp = RegistrationService.register(Map.merge(@valid_attrs, %{email: "other@mail.com"}))

      assert {:ok, %{org: org, user: user}} = resp

      {:error, :user, user, _b} = RegistrationService.register(@valid_attrs)

      assert user.errors[:mobile_number] == {"has already been taken", []}
    end

    test "validations" do
      assert {:error, reg_cs} = RegistrationService.register(%{})

      assert reg_cs.errors[:email]
      assert reg_cs.errors[:password]
      assert reg_cs.errors[:name]
      refute reg_cs.errors[:category]
      assert reg_cs.errors[:address]

      assert {:error, reg_cs} = RegistrationService.register(%{email: "fake@mail", password: "demo123", addres: "Small"})

      assert reg_cs.errors[:email]
      assert reg_cs.errors[:password]
    end

  end
end
