defmodule Publit.UserClientTest do
  use Publit.ModelCase

  alias Publit.UserClient

  @valid_attrs %{full_name: "Amaru Barroso", email: "amaru@mail.com",
      password: "demo1234", mobile_number: "73732655", extra_data: %{"os_player_id" => "fbclitoken123"}}
  @invalid_attrs %{email: "to", mobile_number: "22"}

  describe "create" do
    test "OK" do
      {:ok, user} = UserClient.create(@valid_attrs)
      assert %UserClient{} = user

      assert user.encrypted_password
      assert user.email == "amaru@mail.com"
      assert user.mobile_number == "73732655"
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

  @player_id "e95fb4a9-50d3-41ae-a8d3-1465f00611e6"

  describe "update_player_id" do
    test "OK" do
      {:ok, user} = UserClient.create(@valid_attrs)

      {:ok, user} = UserClient.update_os_player_id(user, @player_id)

      t = to_string(user.extra_data["os_updated_at"])

      user = Repo.get(UserClient, user.id)

      assert user.extra_data["os_player_id"] == @player_id
      assert user.extra_data["os_updated_at"] == t
    end

    test "does not override" do
      {:ok, user} = Repo.insert(%UserClient{
        full_name: "Amaru Barroso", mobile_number: "12345678", email: "amaru@mail.com",
        encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234"),
        extra_data: %{a: "data", b: 123, dec: 12.3, bool: true}
      })

      user = Repo.get(UserClient, user.id)
      {:ok, user} = UserClient.update_os_player_id(user, @player_id)

      user = Repo.get(UserClient, user.id)

      assert user.extra_data["a"] == "data"
      assert user.extra_data["b"] == 123
      assert user.extra_data["dec"] == 12.3
      assert user.extra_data["bool"] == true


      assert user.extra_data["os_player_id"] == @player_id
      assert user.extra_data["os_updated_at"]
    end
  end
end
