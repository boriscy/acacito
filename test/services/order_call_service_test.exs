defmodule Publit.OrderCallServiceTest do
  use Publit.ModelCase

  alias Publit.{Order, OrderCall, OrderCallService, UserTransport}

  @user_id Ecto.UUID.generate()

  describe "update_transport" do
    test "OK" do
      {uc, org} = {insert(:user_client), insert(:organization)}
      order = create_order_only(uc, org)

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
      assert order.transport.responded_at
      assert order.transport.vehicle == "motorcycle"
      assert order.transport.plate == ut.plate

      log = order.log |> List.last()

      assert log[:type] == "update_transport"
      assert log[:user_transport]
      assert log[:user_transport_id]

      assert Repo.one(from oc in OrderCall, select: count(oc.id)) == 0

      resp = Publit.MessageApiMock.get_data()

      assert resp[:msg][:order_call_id] == oc.id
      assert resp[:msg][:order_id] == order.id
      assert resp[:msg][:user_transport_id] == ut.id
      assert resp[:msg][:status] == "order:answered"

    end

    test "empty" do
      order = %Order{id: Ecto.UUID.generate()}

      assert OrderCallService.accept(order, %UserTransport{}, %{}) == :empty
    end

    test "empty2" do
      {uc, org} = {insert(:user_client), insert(:organization)}
      order = create_order_only(uc, org)

      {:ok, order} = Order.next_status(order, @user_id)
      ut = insert(:user_transport, status: "listen")

      assert :empty = OrderCallService.accept(order, ut, %{final_price: Decimal.new("7")})
    end

    test "error" do
      {uc, org} = {insert(:user_client), insert(:organization)}
      order = create_order_only(uc, org)

      {:ok, order} = Order.next_status(order, @user_id)
      ut = insert(:user_transport, status: "listen")

      insert(:order_call, transport_ids: [ut.id], order_id: order.id, status: "delivered")

      assert {:error, :order, cs} = OrderCallService.accept(order, ut, %{final_price: Decimal.new("-7")})
      assert cs.changes.transport.errors[:final_price]
    end

  end

end
