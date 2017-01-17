defmodule Publit.UserTransportTest do
  use Publit.ModelCase

  alias Publit.UserTransport

  @valid_attrs %{full_name: "Julio Juarez", email: "julio@mail.com", password: "demo1234", mobile_number: "73732655", type: "jejeje"}
  @invalid_attrs %{email: "to", mobile_number: "22"}

  describe "create" do
    test "OK" do
      {:ok, user} = UserTransport.create(@valid_attrs)

      assert user.encrypted_password
      assert user.email == "julio@mail.com"
      assert user.mobile_number == "73732655"
    end

    test "Error invalid email, blank password" do
      {:error, cs} = UserTransport.create(@invalid_attrs)

      assert cs.valid? == false
      assert cs.errors[:email]
      assert cs.errors[:password]
      assert cs.errors[:full_name]
      assert cs.errors[:mobile_number]
    end

  end

end
