defmodule Publit.OrderChannelTest do
  use Publit.ChannelCase
  alias Publit.{OrganizationChannel}

  @endpoind Publit.Endpoint

  setup do
    org = insert(:organization)
    {:ok, _, socket} = socket("user:id", %{data: 1})
    |> subscribe_and_join(OrganizationChannel, "organizations:#{org.id}", %{"id" => 3})

    {:ok, socket: socket, org: org}
  end

  test "move_next", %{socket: socket, org: org} do
    uc = insert(:user_client)
    order = create_order_only(uc, org)
    Publit.OrganizationChannel.broadcast_order(order)
    ord = Publit.Api.OrderView.to_api(order)
    #assert_reply ref, :ok, %{}
    assert_broadcast "new:order", ord
  end
end
