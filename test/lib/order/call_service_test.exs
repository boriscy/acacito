defmodule Publit.Order.CallServiceTest do
  use Publit.ModelCase
  import Publit.Gettext

  alias Publit.{Order, UserTransport, Repo}

  describe "update_transport" do
    test "OK" do
      Agent.start_link(fn -> %{} end, name: :api_mock)

      {uc, org} = {insert(:user_client), insert(:organization)}
      order = create_order_only(uc, org, %{status: "process"})
      insert(:order_log, order_id: order.id)

      ut = insert(:user_transport, status: "listen")
      ut2 = insert(:user_transport, status: "listen", mobile_number: "99887766", extra_data: %{"device_token" => "devtoken3456789"})
      assert order.status == "process"

      oc = insert(:order_call, transport_ids: [ut.id, ut2.id], order_id: order.id, status: "delivered")
      {:ok, order, _pid} = Order.CallService.accept(order, ut, %{final_price: Decimal.new("7")})

      assert order.status == "transport"
      assert order.user_transport_id == ut.id

      assert order.transport.transporter_id == ut.id
      assert order.transport.transporter_name == ut.full_name
      assert order.transport.final_price == Decimal.new("7")
      assert order.transport.responded_at
      assert order.transport.vehicle == "motorcycle"
      assert order.transport.plate == ut.plate

      user_t = Repo.get(UserTransport, ut.id)
      assert Enum.count(user_t.orders) == 1
      ut_order = user_t.orders |> List.first()

      assert ut_order["id"] == order.id
      assert ut_order["status"] == "transporting"

      log = Repo.get_by(Order.Log, order_id: order.id, log_type: "Order")
      lg = log.log |> List.last()

      assert lg["user_id"] == ut.id

      assert Repo.one(from oc in Order.Call, select: count(oc.id)) == 0

      resp = Publit.MessageApiMock.get_data()

      #assert resp[:msg][:message] == gettext("New order from %{org}", org: org.name)
      assert resp[:msg][:data][:order_call_id] == oc.id
      ord = resp[:msg][:data][:order]
      assert ord[:id] == order.id
      IO.inspect ord
    end

    test "empty" do
      order = %Order{id: Ecto.UUID.generate()}

      assert Order.CallService.accept(order, %UserTransport{}, %{}) == :empty
    end

    test "empty2" do
      {uc, org} = {insert(:user_client), insert(:organization)}
      order = create_order_only(uc, org, %{status: "process"})

      ut = insert(:user_transport, status: "listen")

      assert :empty = Order.CallService.accept(order, ut, %{final_price: Decimal.new("7")})
    end

    test "error" do
      {uc, org} = {insert(:user_client), insert(:organization)}
      order = create_order_only(uc, org, %{status: "process"})

      ut = insert(:user_transport, status: "listen")

      insert(:order_call, transport_ids: [ut.id], order_id: order.id, status: "delivered")

      assert {:error, :order, cs} = Order.CallService.accept(order, ut, %{final_price: Decimal.new("-7")})
      assert cs.changes.transport.errors[:final_price]
    end

  end

end
