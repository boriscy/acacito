defmodule PublitWeb.UserSocketTest do
  use PublitWeb.ChannelCase, async: true

  alias PublitWeb.{UserSocket}

  test "authenticate" do
    token = Phoenix.Token.sign(@endpoint, "user_id", "user123")

    assert {:ok, socket} = connect(UserSocket, %{token: token})
    assert socket.assigns.user_id == "user123"
  end

  test "unauthenticated" do
    assert :error == connect(UserSocket, %{token: "tokeninvalid"})
  end
end
