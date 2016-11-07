defmodule Publit.UserTest do
  use Publit.ModelCase

  alias Publit.User

  @valid_attrs %{email: "amaru@mail.com", password: "demo1234"}
  @invalid_attrs %{email: "to"}

  describe "create" do
    test "OK" do
      {:ok, user} = User.create(@valid_attrs)

      assert user.encrypted_password
      assert user.email == "amaru@mail.com"
    end

    test "Error invalid email, blank password" do
      {:error, cs} = User.create(@invalid_attrs)

      assert cs.valid? == false
      assert cs.errors[:email]
      assert cs.errors[:password]
    end

    test "Error blank email, short password" do
      {:error, cs} = User.create(%{email: "", password: "demo"})

      assert cs.valid? == false
      assert cs.errors[:email]
      assert cs.errors[:password]
    end
  end

end
