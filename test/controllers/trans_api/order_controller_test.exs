defmodule Publit.TransApi.OrderControllerTest do
  use Publit.ConnCase, async: false
  import Mock

  alias Publit.{OrderCall, OrderTransport}

  setup do
    ut = insert(:user_transport)

    conn = build_conn() |> assign(:current_user_transport, ut)

    %{conn: conn, ut: ut}
  end


  defp create_order_call(order, params \\ %{status: "delivered"}) do
    params = Map.merge(params, %{order_id: order.id})
    {:ok, oc} = Repo.insert(Map.merge(%OrderCall{}, params))
    oc
  end


  describe "PUT /trans_api/accept/:order_id" do
    test_with_mock "OK", %{conn: conn}, Publit.OrganizationChannel, [],
      [broadcast_order: fn(_a, _b) -> :ok end] do
      org = insert(:organization)
      uc = insert(:user_client)
      order = create_order_only(uc, org)

      oc = create_order_call(order)

      conn = put(conn, "/trans_api/accept/#{order.id}", %{"order_call_id" => oc.id})

      json = Poison.decode!(conn.resp_body)
      ord = json["order"]
      assert ord["status"] == "transport"
      assert ord["transport"]["final_price"] == to_string(order.transport.calculated_price)

      assert called Publit.OrganizationChannel.broadcast_order(:_, "order:updated")
    end

    test "Error", %{conn: conn} do
      org = insert(:organization)
      uc = insert(:user_client)
      order = create_order_only(uc, org, %{transport: %OrderTransport{calculated_price: Decimal.new("-5")} })

      oc = create_order_call(order)

      conn = put(conn, "/trans_api/accept/#{order.id}", %{"order_call_id" => oc.id})

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      json = Poison.decode!(conn.resp_body)

      assert json["errors"]["transport"]["final_price"]
    end

    test "Empty", %{conn: conn} do
      org = insert(:organization)
      uc = insert(:user_client)
      order = create_order_only(uc, org, %{transport: %OrderTransport{calculated_price: Decimal.new("-5")} })

      #oc = create_order_call(order)

      conn = put(conn, "/trans_api/accept/#{order.id}", %{"order_call_id" => "123"})

      assert conn.status == Plug.Conn.Status.code(:precondition_failed)

      json = Poison.decode!(conn.resp_body)
      assert json["message"] == gettext("No transport available")
    end

    test "not_found", %{conn: conn} do
      id = Ecto.UUID.generate()
      conn = put(conn, "/trans_api/accept/#{id}", %{"order_call_id" => id})
      assert conn.status == 404

      json = Poison.decode!(conn.resp_body)
      assert json["message"] == gettext("Order not found")
    end

  end

end
