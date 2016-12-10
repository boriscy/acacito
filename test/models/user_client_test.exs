defmodule Publit.UserClientTest do
  use Publit.ModelCase

  alias Publit.UserClient

  @valid_attrs %{full_name: "Amaru Barroso", email: "amaru@mail.com", password: "demo1234", mobile_number: "73732655", type: "jejeje"}
  @invalid_attrs %{email: "to"}

  describe "create" do
    test "OK" do
      {:ok, user} = UserClient.create(@valid_attrs)

      assert user.encrypted_password
      assert user.email == "amaru@mail.com"
      assert user.mobile_number == "73732655"
      assert user.type == "client"
    end

    test "Error invalid email, blank password" do
      {:error, cs} = UserClient.create(@invalid_attrs)

      assert cs.valid? == false
      assert cs.errors[:email]
      assert cs.errors[:password]
      assert cs.errors[:full_name]
      assert cs.errors[:mobile_number]
    end

  end

end

