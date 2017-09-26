defmodule Publit.UserClientTest do
  use Publit.ModelCase
  import PublitWeb.Gettext
  alias Publit.{UserClient, Repo}

  @valid_attrs %{full_name: "Amaru Barroso", email: "amaru@mail.com",
      password: "demo1234", mobile_number: "73732655", extra_data: %{"device_token" => "devtoken123"}}
  @invalid_attrs %{email: "to", mobile_number: "22"}

  describe "create" do
    test "OK" do
      {:ok, user} = UserClient.create(%{"mobile_number" => "73732655", "full_name" => "Amaru Barroso"})

      assert user.mobile_verification_token |> String.length() == 8
      assert user.mobile_verification_send_at
    end

    test "Error" do
      {:error, cs} = UserClient.create(%{})

      assert cs.valid? == false
      assert cs.errors[:full_name]
      assert cs.errors[:mobile_number]
    end

    test "full_name validation" do
      {:error, cs} = UserClient.create(%{"full_name" => ""})
      assert cs.errors[:full_name]

      {:error, cs} = UserClient.create(%{"full_name" => "Pab"})
      assert cs.errors[:full_name]
    end

  end

  test "number validation" do
    {:error, cs} = UserClient.create(%{"mobile_number" => "33445566"})
    assert cs.errors[:mobile_number]

    {:error, cs} = UserClient.create(%{"mobile_number" => "7344556"})
    assert cs.errors[:mobile_number]

    {:error, cs} = UserClient.create(%{"mobile_number" => "73445566"})
    refute cs.errors[:mobile_number]

    {:error, cs} = UserClient.create(%{"mobile_number" => "63445566"})
    refute cs.errors[:mobile_number]
  end

  test "duplicated mobile_number" do
    {:ok, uc} = UserClient.create(%{"mobile_number" => "73732655", "full_name" => "Amaru Barroso"})

    assert {:error, cs} = UserClient.create(%{"mobile_number" => "73732655", "full_name" => "Amaru Barroso"})

    assert cs.errors[:mobile_number]
  end

  @device_token "14d14fa953ac53aaff8416"


end
