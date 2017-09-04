defmodule PublitWeb.OrderChannelTest do
  use PublitWeb.ChannelCase
  alias PublitWeb.{OrganizationChannel}

  setup do
    org = insert(:organization)
    {:ok, _, socket} = socket("user:id", %{data: 1})
    |> subscribe_and_join(OrganizationChannel, "organizations:#{org.id}", %{})

    {:ok, socket: socket, org: org}
  end

  test "broadcast order:created", %{org: org} do
    uc = insert(:user_client)
    order = create_order_only(uc, org)
    PublitWeb.OrganizationChannel.broadcast_order(order)
    ord = PublitWeb.Api.OrderView.to_api(order)

    assert_broadcast "order:created", ord
  end

  test "broadcast order:updated", %{org: org} do
    uc = insert(:user_client)
    order = create_order_only(uc, org)
    PublitWeb.OrganizationChannel.broadcast_order(order, "order:updated")
    ord = PublitWeb.Api.OrderView.to_api(order)

    assert_broadcast "order:updated", ord
  end

end
