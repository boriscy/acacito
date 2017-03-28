defmodule Publit.UserAuthenticationTest do
  use Publit.ConnCase
  alias Publit.{UserAuthentication, UserTransport}

  test "changeset" do
    user = UserAuthentication.changeset(%{"email" => "amaru@mail.com", "password" => "demo1234"})

    assert user.changes.email == "amaru@mail.com"
    assert user.changes[:password] == nil
  end

  test "valid_user true" do
    insert(:user, email: "lucas@mail.com")

    {:ok, user} = UserAuthentication.valid_user(%{"email" => "lucas@mail.com", "password" => "demo1234"})
    assert user.id
  end

  test "valid_user false wrong password" do
    insert(:user, email: "lucas@mail.com")

    {:error, cs} = UserAuthentication.valid_user(%{"email" => "lucas@mail.com", "password" => "demo123"})

    assert cs.valid? == false
    assert cs.changes.email == "lucas@mail.com"
    assert cs.errors[:password]
  end

  test "valid_user false invalid user" do
    {:error, cs} = UserAuthentication.valid_user(%{"email" => "amaru@mail.com", "password" => "demo1234"})
    assert cs.changes.email == "amaru@mail.com"
  end

  test "encrypt_user_id" do
    user = insert(:user)

    token = UserAuthentication.encrypt_user_id(user.id)
    {:ok, user_id} = Phoenix.Token.verify(Publit.Endpoint, "user_id", token)
    assert user_id == user.id
  end

  test "valid_user_transport" do
    user = insert(:user_transport)

    assert {:ok, user} = UserAuthentication.valid_user_transport(%{"email" => user.email, "password" => "demo1234"})
    assert %UserTransport{} = user

    assert {:ok, user} = UserAuthentication.valid_user_transport(%{"email" => user.mobile_number, "password" => "demo1234"})
    assert %UserTransport{} = user
  end
end
