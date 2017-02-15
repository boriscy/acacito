defmodule Publit.OrderCallServiceTest do
  use Publit.ModelCase

  alias Publit.{Order, OrderCall, OrderCallService}

  @user_id Ecto.UUID.generate()

  describe "update_transport" do
    test "from process to transport" do
      {uc, org} = {insert(:user_client), insert(:organization)}
      order = create_only_order(uc, org)

      {:ok, order} = Order.next_status(order, @user_id)
      ut = insert(:user_transport, status: "listen")
      ut2 = insert(:user_transport, status: "listen", mobile_number: "99887766", extra_data: %{"fb_token" => "fb3456789"})

      oc = insert(:order_call, transport_ids: [ut.id, ut2.id], order_id: order.id, status: "delivered")
      {:ok, order, _pid} = OrderCallService.accept(order, ut, %{final_price: Decimal.new("7")})

      assert order.status == "transport"
      assert order.user_transport_id == ut.id
      assert order.transport.transporter_id == ut.id
      assert order.transport.transporter_name == ut.full_name
      assert order.transport.final_price == Decimal.new("7")

      assert Repo.one(from oc in OrderCall, select: count(oc.id)) == 0

      resp = Publit.MessageApiMock.get_data()

      assert resp[:msg][:order_call_id] == oc.id
      assert resp[:msg][:order_id] == order.id
      assert resp[:msg][:user_transport_id] == ut.id
      assert resp[:msg][:status] == "order:answered"
    end
  end

end
