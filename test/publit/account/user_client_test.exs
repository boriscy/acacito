defmodule Publit.UserClientTest do
  use Publit.ModelCase
  import PublitWeb.Gettext
  alias Publit.{UserClient, Repo}

  @valid_attrs %{full_name: "Amaru Barroso", email: "amaru@mail.com",
      password: "demo1234", mobile_number: "59173732655", extra_data: %{"device_token" => "devtoken123"}}
  @invalid_attrs %{email: "to", mobile_number: "22"}

  describe "create" do
    test "OK" do
      {:ok, user} = UserClient.create(%{"mobile_number" => "73732655", "full_name" => "Amaru Barroso"})

      assert user.mobile_verification_token |> String.length() == 6
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

  describe "check_mobile_verification_token" do
    test "OK" do
      {:ok, uc} = UserClient.create(%{"mobile_number" => "73732655", "full_name" => "Amaru Barroso"})

      assert uc.verified == false
      token = uc.mobile_verification_token

      assert {:ok, uc} = UserClient.check_mobile_verification_token("73732655", token)

      assert uc.verified == true
      assert uc.mobile_verification_token == "V" <> token
    end

    test "time" do
      {:ok, uc} = UserClient.create(%{"mobile_number" => "73732655", "full_name" => "Amaru Barroso"})

      t = NaiveDateTime.add(uc.mobile_verification_send_at, -3601)

      {:ok, uc} = Ecto.Changeset.change(uc) |> Ecto.Changeset.put_change(:mobile_verification_send_at, t) |> Repo.update()


      assert :error = UserClient.check_mobile_verification_token("73732655", uc.mobile_verification_token)
    end

    test "invalid token" do
      {:ok, uc} = UserClient.create(%{"mobile_number" => "73732655", "full_name" => "Amaru Barroso"})

      assert :error = UserClient.check_mobile_verification_token("73732655", "je12345")
    end


    test "not found" do
      assert :error = UserClient.check_mobile_verification_token("73732655", "je12345tt")
    end

  end

end
