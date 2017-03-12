defmodule Publit.Order.QueryTest do
  use Publit.ModelCase
  import Publit.Support.Session, only: [create_user_org: 1]

  alias Publit.{Order, ProductVariation}

  test "active, all" do
    {uc, org} = {insert(:user_client), insert(:organization)}
    ut = insert(:user_transport)

    create_order_only(uc, org, %{status: "new"})
    create_order_only(uc, org, %{status: "process"})
    create_order_only(uc, org, %{status: "transport", user_transport_id: ut.id})
    create_order_only(uc, org, %{status: "transporting", user_transport_id: ut.id})
    create_order_only(uc, org, %{status: "delivered"})

    assert Enum.count(Order.Query.active(org.id)) == 4

    assert Enum.count(Order.Query.transport_orders(ut.id)) == 2

    assert Enum.count(Order.Query.user_orders(uc.id)) == 5
  end

end
