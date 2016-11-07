defmodule Publit.UserAuthTest do
  use Publit.ConnCase
  alias Publit.{UserAuth}

  test "changeset" do
    user = UserAuth.changeset(%{"email" => "amaru@mail.com", "password" => "demo1234"})

    assert user.email == "amaru@mail.com"
    assert user.password == nil
  end

  test "valid_user true" do
    user = insert(:user)

    {:ok, user} = UserAuth.valid_user(%{"email" => "amaru@mail.com", "password" => "demo1234"})
    assert user.id
  end

  test "valid_user false wrong password" do
    user = insert(:user)

    {:error, cs} = UserAuth.valid_user(%{"email" => "amaru@mail.com", "password" => "demo123"})
    assert cs.email == "amaru@mail.com"
  end

  test "valid_user false invalid user" do
    {:error, cs} = UserAuth.valid_user(%{"email" => "amaru@mail.com", "password" => "demo1234"})
    assert cs.email == "amaru@mail.com"
  end
end
