defmodule Publit.OrderCallServiceTest do
  use Publit.ModelCase

  alias Publit.{Order, OrderCallService}

  @user_id Ecto.UUID.generate()

  describe "update_transport" do
    test "from process to transport" do
      {uc, org} = {insert(:user_client), insert(:organization)}
      order = create_only_order(uc, org)

      {:ok, order} = Order.next_status(order, @user_id)
      ut = insert(:user_transport, status: "listen")
      ut2 = insert(:user_transport, status: "listen", mobile_number: "99887766")
      oc = insert(:order_call, transport_ids: [ut.id, ut2.id], order_id: order.id)

      {:ok, order} = OrderServiceCall.accept(order, ut, %{final_price: Decimal.new("7")})

      assert order.user_transport_id == ut.id
      assert order.transport.transporter_id == ut.id
      assert order.transport.transporter_name == ut.full_name
      assert order.transport.final_price == Decimal.new("7")
    end
  end

end
