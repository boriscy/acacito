defmodule Publit.TransApi.OrderControllerTest do
  use Publit.ConnCase, async: false
  import Mock

  alias Publit.{Order, UserTransport, Repo}

  setup do
    ut = insert(:user_transport)

    token = Phoenix.Token.sign(Publit.Endpoint, "user_id", ut.id)

    conn = build_conn()

    %{conn: conn, ut: ut, token: token}
  end


  defp create_order_call(order, params \\ %{status: "new"}) do
    params = Map.merge(params, %{order_id: order.id})
    {:ok, oc} = Repo.insert(Map.merge(%Order.Call{}, params))
    oc
  end

  @pos %Geo.Point{coordinates: { -63.8748, -18.1778 }, srid: nil}

  describe "GET /trans_api/orders" do
    test "OK", %{conn: conn, ut: ut, token: token} do
      Agent.start_link(fn -> [] end, name: :api_mock)
      org = insert(:organization)
      uc = insert(:user_client)

      insert(:order, %{user_client_id: uc.id, client_pos: @pos, organization_pos: @pos,
        organization_id: org.id, user_transport_id: ut.id, status: "transport"})
      insert(:order, %{user_client_id: uc.id, client_pos: @pos, organization_pos: @pos,
        organization_id: org.id, status: "transport"})

      conn = conn
      |> put_req_header("authorization", token)
      |> get("/trans_api/orders?status[0]=transport&status[1]=transporting")

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert Enum.count(json["orders"]) == 1

      ord = List.first(json["orders"])

      assert ord["status"] == "transport"
      assert ord["user_transport_id"] == ut.id
    end
  end

  describe "PUT /trans_api/accept/:order_id" do
    test_with_mock "OK", %{conn: conn, token: token}, Publit.OrganizationChannel, [],
      [broadcast_order: fn(_a, _b) -> :ok end] do
      Agent.start_link(fn -> [] end, name: :api_mock)
      org = insert(:organization)
      uc = insert(:user_client)
      order = create_order_only(uc, org)

      oc = create_order_call(order, %{status: "delivered"})

      conn = conn
      |> put_req_header("authorization", token)
      |> put("/trans_api/accept/#{order.id}", %{"order_call_id" => oc.id})

      json = Poison.decode!(conn.resp_body)
      ord = json["order"]
      assert ord["status"] == "transport"
      assert ord["transport"]["final_price"] == to_string(order.transport.calculated_price)

      assert called Publit.OrganizationChannel.broadcast_order(:_, "order:updated")
    end

    test "Error", %{conn: conn, token: token} do
      Agent.start_link(fn -> [] end, name: :api_mock)
      org = insert(:organization)
      uc = insert(:user_client)
      order = create_order_only(uc, org, %{transport: %Order.Transport{calculated_price: Decimal.new("-5")} })

      oc = create_order_call(order, %{status: "delivered"})

      conn = conn
      |> put_req_header("authorization", token)
      |> put("/trans_api/accept/#{order.id}", %{"order_call_id" => oc.id})

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      json = Poison.decode!(conn.resp_body)

      assert json["errors"]["transport"]["final_price"]
    end

    test "Empty", %{conn: conn, token: token} do
      Agent.start_link(fn -> [] end, name: :api_mock)
      org = insert(:organization)
      uc = insert(:user_client)
      order = create_order_only(uc, org, %{transport: %Order.Transport{calculated_price: Decimal.new("-5")} })

      conn = conn
      |> put_req_header("authorization", token)
      |> put("/trans_api/accept/#{order.id}", %{"order_call_id" => "123"})

      assert conn.status == Plug.Conn.Status.code(:precondition_failed)

      json = Poison.decode!(conn.resp_body)
      assert json["message"] == gettext("No transport available")
    end

    test "not_found", %{conn: conn, token: token} do
      Agent.start_link(fn -> [] end, name: :api_mock)
      id = Ecto.UUID.generate()
      conn = conn
      |> put_req_header("authorization", token)
      |> put("/trans_api/accept/#{id}", %{"order_call_id" => id})

      assert conn.status == 404

      json = Poison.decode!(conn.resp_body)
      assert json["message"] == gettext("Order not found")
    end

  end


  describe "PUT /trans_api/deliver/:order_id" do
    @pos %{"position" =>
            %{"altitude" => 1687,
             "pos" => %{"coordinates" => [-63.86842910000001, -18.189872799999996], "type" => "Point"},
             "speed" => 30}}

    test "OK", %{conn: conn, ut: ut} do
      Agent.start_link(fn -> [] end, name: :api_mock)
      uc = insert(:user_client)
      org = insert(:organization)
      order = create_order_only(uc, org, %{status: "transporting"})

      {:ok, order} = Ecto.Changeset.change(order)
      |> Ecto.Changeset.put_change(:user_transport_id, ut.id)
      |> Publit.Repo.update()

      {:ok, ut} = Ecto.Changeset.change(ut)
      |> Ecto.Changeset.put_change(:orders, [%{"id" => order.id, "status" => order.status}])
      |> Publit.Repo.update()

      conn = conn
      |> assign(:current_user_transport, ut)
      |> put("/trans_api/deliver/#{order.id}", %{"poisition" => @pos})

      assert conn.status == 200

      json = Poison.decode!(conn.resp_body)

      assert json["order"]["status"] == "delivered"

      ut = Repo.get(UserTransport, ut.id)

      assert ut.orders == []
    end
  end

end
