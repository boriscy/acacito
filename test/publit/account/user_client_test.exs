defmodule Publit.UserClientTest do
  use Publit.ModelCase, async: false
  import PublitWeb.Gettext
  alias Publit.{UserClient, Repo}

  @valid_attrs %{full_name: "Amaru Barroso", email: "amaru@mail.com",
      password: "demo1234", mobile_number: "59173732655", extra_data: %{"device_token" => "devtoken123"}}
  @invalid_attrs %{email: "to", mobile_number: "22"}

  describe "create" do
    test "OK" do
      {:ok, user} = UserClient.create(%{"mobile_number" => "59173732655", "full_name" => "Amaru Barroso"})

      assert user.mobile_verification_token |> String.length() == 6
      assert user.mobile_verification_send_at
    end

    test "Error" do
      {:error, cs} = UserClient.create(%{})

      assert cs.valid? == false
      assert cs.errors[:full_name]
      assert cs.errors[:mobile_number]
    end

  end

  test "number validation" do
    {:error, cs} = UserClient.create(%{"mobile_number" => "59133445566"})
    assert cs.errors[:mobile_number]

    {:error, cs} = UserClient.create(%{"mobile_number" => "5917344556"})
    assert cs.errors[:mobile_number]

    {:error, cs} = UserClient.create(%{"mobile_number" => "59173445566"})
    refute cs.errors[:mobile_number]

    {:error, cs} = UserClient.create(%{"mobile_number" => "59163445566"})
    refute cs.errors[:mobile_number]
  end

  @device_token "14d14fa953ac53aaff8416"

  describe "update_device_token" do
    test "OK" do
      Agent.start_link(fn -> %{} end, name: :sms_mock)

      {:ok, user} = UserClient.create(@valid_attrs)

      {:ok, user} = UserClient.update_device_token(user, @device_token)

      t = to_string(user.extra_data["device_token_updated_at"])

      user = Repo.get(UserClient, user.id)

      assert user.extra_data["device_token"] == @device_token
      assert user.extra_data["device_token_updated_at"] == t

      Agent.stop(:sms_mock)
    end

    test "does not override" do
      Agent.start_link(fn -> %{} end, name: :sms_mock)

      {:ok, user} = Repo.insert(%UserClient{
        full_name: "Amaru Barroso", mobile_number: "12345678", email: "amaru@mail.com",
        encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234"),
        extra_data: %{a: "data", b: 123, dec: 12.3, bool: true}
      })

      user = Repo.get(UserClient, user.id)
      {:ok, user} = UserClient.update_device_token(user, @device_token)

      user = Repo.get(UserClient, user.id)

      assert user.extra_data["a"] == "data"
      assert user.extra_data["b"] == 123
      assert user.extra_data["dec"] == 12.3
      assert user.extra_data["bool"] == true


      assert user.extra_data["device_token"] == @device_token
      assert user.extra_data["device_token_updated_at"]

      Agent.stop(:sms_mock)
    end
  end
end
