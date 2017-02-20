defmodule Publit.OrderChannelTest do
  use Publit.ChannelCase
  alias Publit.{OrganizationChannel}

  setup do
    org = insert(:organization)
    {:ok, _, socket} = socket("user:id", %{data: 1})
    |> subscribe_and_join(OrganizationChannel, "organizations:#{org.id}", %{})

    {:ok, socket: socket, org: org}
  end

  test "broadcast order:created", %{org: org} do
    uc = insert(:user_client)
    order = create_order_only(uc, org)
    Publit.OrganizationChannel.broadcast_order(order)
    ord = Publit.Api.OrderView.to_api(order)

    assert_broadcast "order:created", ord
  end

  test "broadcast order:updated", %{org: org} do
    uc = insert(:user_client)
    order = create_order_only(uc, org)
    Publit.OrganizationChannel.broadcast_order(order, "order:updated")
    ord = Publit.Api.OrderView.to_api(order)

    assert_broadcast "order:updated", ord
  end

end
