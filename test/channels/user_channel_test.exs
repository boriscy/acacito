defmodule PublitWeb.UserChannelTest do
  use PublitWeb.ChannelCase
  alias PublitWeb.{UserChannel}

  setup do
    org = insert(:organization)
    uc = insert(:user_client)

    {:ok, _, socket} = socket("user:id", %{data: 1})
    |> subscribe_and_join(UserChannel, "users:#{uc.id}", %{})

    {:ok, socket: socket, org: org, user: uc}
  end

  test "broadcast order:created", %{org: org, user: user} do
    order = create_order_only(user, org)
    UserChannel.broadcast_order(order)
    ord = PublitWeb.Api.OrderView.to_api(order)

    assert_broadcast "order:updated", ord
  end
end
