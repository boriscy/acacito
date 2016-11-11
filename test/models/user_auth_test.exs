defmodule Publit.UserAuthTest do
  use Publit.ConnCase
  alias Publit.{UserAuth}

  test "changeset" do
    user = UserAuth.changeset(%{"email" => "amaru@mail.com", "password" => "demo1234"})

    assert user.changes.email == "amaru@mail.com"
    assert user.changes[:password] == nil
  end

  test "valid_user true" do
    insert(:user)

    {:ok, user} = UserAuth.valid_user(%{"email" => "amaru@mail.com", "password" => "demo1234"})
    assert user.id
  end

  test "valid_user false wrong password" do
    insert(:user)

    {:error, cs} = UserAuth.valid_user(%{"email" => "amaru@mail.com", "password" => "demo123"})
    assert cs.changes.email == "amaru@mail.com"
  end

  test "valid_user false invalid user" do
    {:error, cs} = UserAuth.valid_user(%{"email" => "amaru@mail.com", "password" => "demo1234"})
    assert cs.changes.email == "amaru@mail.com"
  end

  test "encrypt_user" do
    user = insert(:user)

    token = UserAuth.encrypt_user(user)
    {:ok, user_id} = Phoenix.Token.verify(Publit.Endpoint, "user_id", token)
    assert user_id == user.id
  end
end
