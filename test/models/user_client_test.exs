defmodule Publit.UserClientTest do
  use Publit.ModelCase
  alias Publit.{UserClient, Repo}

  @valid_attrs %{full_name: "Amaru Barroso", email: "amaru@mail.com",
      password: "demo1234", mobile_number: "59173732655", extra_data: %{"device_token" => "devtoken123"}}
  @invalid_attrs %{email: "to", mobile_number: "22"}

  describe "create" do
    test "OK" do
      Agent.start_link(fn -> %{} end, name: :sms_mock)

      {:ok, user} = UserClient.create(@valid_attrs)
      assert %UserClient{} = user

      assert user.encrypted_password
      assert user.email == "amaru@mail.com"
      assert user.mobile_number == "59173732655"

      assert user.extra_data["mobile_number_key"]
      m_key = Publit.AES.decrypt(user.extra_data["mobile_number_key"])
      assert String.length(m_key) == 6

      assert user.extra_data["mobile_number_send_at"]
      assert user.extra_data["mobile_number_sends"] == 0

      refute user.verified

      Process.sleep(120)

      u = Repo.get(UserClient, user.id)

      assert u.extra_data["mobile_number_sends"] == 1
      msg = Agent.get(:sms_mock, fn(v) -> v end)
      num = Regex.scan(~r/\d+/, msg[:msg]) |> List.first() |> List.first()

      {:ok, user} = Publit.UserUtil.verify_mobile_number(user, num)

      assert user.verified
    end

    test "Created error verify" do
      Agent.start_link(fn -> %{status: "9"} end, name: :sms_mock)

      {:ok, user} = UserClient.create(@valid_attrs)
      assert %UserClient{} = user

      assert user.encrypted_password
      assert user.email == "amaru@mail.com"
      assert user.mobile_number == "59173732655"

      assert user.extra_data["mobile_number_key"]
      assert user.extra_data["mobile_number_key"]

      assert user.extra_data["mobile_number_send_at"]
      assert user.extra_data["mobile_number_sends"] == 0

      refute user.verified

      Process.sleep(120)

      user = Repo.get(UserClient, user.id)

      assert user.extra_data["mobile_number_sends"] == 1
      refute user.verified

      Agent.update(:sms_mock, fn(v) -> Map.merge(v, %{status: "0"}) end)
      {:ok, user} = Publit.UserUtil.resend_verification_number(user, "59177889911")

      Process.sleep(120)

      msg = Agent.get(:sms_mock, fn(v) -> v end)
      num = Regex.scan(~r/\d+/, msg[:msg]) |> List.first() |> List.first()

      {:ok, user} = Publit.UserUtil.verify_mobile_number(user, num)

      assert user.verified
    end

    test "Error invalid email, blank password" do
      Agent.start_link(fn -> %{} end, name: :sms_mock)

      {:error, cs} = UserClient.create(@invalid_attrs)

      assert cs.valid? == false
      assert cs.errors[:email]
      assert cs.errors[:password]
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
    end
  end
end
