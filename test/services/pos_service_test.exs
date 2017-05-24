defmodule PublitPosServiceTest do
  use Publit.ModelCase
  import Mock
  alias Publit.{PosService, Order, Repo, UserTransport}
  require Publit.Gettext
  import Publit.Gettext

  describe "update_position" do
    test "OK" do
      Agent.start_link(fn -> [] end, name: :api_mock)
      pos = %{"coordinates" => [-17.8145819, -63.1560853], "type" => "Point"}
      user = insert(:user_transport)

      assert user.pos == nil

      assert {:ok, user} = PosService.update_pos(user, %{"pos" => pos, "speed" => 30})

      assert user.pos == %Geo.Point{coordinates: {-17.8145819, -63.1560853}, srid: nil}
      assert user.status == "listen"
    end

    test "invalid" do
      Agent.start_link(fn -> [] end, name: :api_mock)
      pos = %{"coordinates" => [-182.8145819, -63.1560853], "type" => "Point"}
      user = insert(:user_transport)

      assert {:error, _cs} = PosService.update_pos(user, %{"pos" => pos})

      pos = %{"coordinates" => [182.8145819, -63.1560853], "type" => "Point"}

      assert {:error, _cs} = PosService.update_pos(user, %{"pos" => pos})

      pos = %{"coordinates" => [82.8145819, -93.1560853], "type" => "Point"}

      assert {:error, _cs} = PosService.update_pos(user, %{"pos" => pos})

      pos = %{"coordinates" => [182.8145819, 93.1560853], "type" => "Point"}

      assert {:error, cs} = PosService.update_pos(user, %{"pos" => pos})

      assert cs.errors[:pos]
    end

    test "invalid no pos" do
      user = insert(:user_transport)
      assert {:error, _cs} = PosService.update_pos(user, %{"pos" => %{}})
    end

  end

  describe "update position and send message if it has orders" do
    test_with_mock "OK near_org", Publit.OrganizationChannel, [],
      [broadcast_order: fn(_a, _b) -> :ok end] do

      org = insert(:organization)
      uc = insert(:user_client)
      order = create_order_only(uc, org, %{status: "transport"})

      {lng, lat} = order.organization_pos.coordinates

      ut = insert(:user_transport, %{status: "order", pos: %Geo.Point{coordinates: {lng + 0.05, lat + 0.05}, srid: nil},
                orders: [%{"id" => order.id, "status" => "transporting"}] })

      pos = %{"coordinates" => [lng + 0.0001, lat - 0.0001], "type" => "Point"}

      #################################
      assert {:ok, ut} = PosService.update_pos(ut, %{"pos" => pos})
      assert ut.pos == %Geo.Point{coordinates: {-18.1799, -63.8701}, srid: nil}

      token = uc.extra_data["device_token"]
      assert token

      assert called Publit.OrganizationChannel.broadcast_order(:_, "order:near_org")

      ord = Repo.get(Order, order.id)
      assert ord.transport.picked_arrived_at

      ut = Repo.get(UserTransport, ut.id)
      ordt = List.first(ut.orders)

      assert ordt["id"] == order.id
      assert ordt["status"] == order.status
    end


    test_with_mock "OK near_client", Publit.OrganizationChannel, [],
      [broadcast_order: fn(_a, _b) -> :ok end] do

      Agent.start_link(fn -> [] end, name: :api_mock)

      org = insert(:organization)
      uc = insert(:user_client)
      order = create_order_only(uc, org, %{status: "transporting"})
      _ol = insert(:order_log, %{order_id: order.id})

      {lng, lat} = order.client_pos.coordinates

      ut = insert(:user_transport, %{status: "order", pos: %Geo.Point{coordinates: {lng + 0.07, lat + 0.07}, srid: nil},
                orders: [%{"id" => order.id, "status" => "transporting"}] })

      #################################
      {:ok, ut} = PosService.update_pos(ut, %{"pos" => %{"coordinates" => [lng + 0.05, lat + 0.05], "type" => "Point"} })

      assert ut.pos == %Geo.Point{coordinates: {lng + 0.05, lat + 0.05}, srid: nil}
      refute called Publit.OrganizationChannel.broadcast_order(:_, "order:near_client")

      ut = Repo.get(UserTransport, ut.id)

      pos = %{"coordinates" => [lng + 0.0001, lat - 0.0001], "type" => "Point"}

      #################################
      assert {:ok, ut} = PosService.update_pos(ut, %{"pos" => pos})
      assert ut.pos == %Geo.Point{coordinates: {lng + 0.0001, lat - 0.0001}, srid: nil}

      token = uc.extra_data["device_token"]
      assert token

      assert Publit.MessageApiMock.get_data() == [%{msg: %{
        title: gettext("Transport near"), message: gettext("Your order is arriving"),
        status: "order:near_client"}, tokens: [token], server_key: "server_key_cli"}]

      assert called Publit.OrganizationChannel.broadcast_order(:_, "order:near_client")

      Process.sleep(100)

      m = Agent.get(:api_mock, fn(v) -> v end) |> List.first()

      assert m.msg.message == gettext("Your order is arriving")
      assert m.msg.status == "order:near_client"
      assert m.server_key == "server_key_cli"
      ord = Repo.get(Order, order.id)

      assert ord.transport.delivered_arrived_at

      ordt = List.first(ut.orders)

      assert ordt["id"] == order.id
      assert ordt["status"] == order.status

      log = Repo.get_by(Order.Log, order_id: order.id, log_type: "Order")

      assert Enum.at(log.log, 0)["pos"] == %{"coordinates" => [-18.1299, -63.8199], "type" => "Point"}
      assert Enum.at(log.log, 0)["type"] == "trans"
      assert Enum.at(log.log, 1)["pos"] == %{"coordinates" => [-18.1798, -63.87], "type" => "Point"}
      assert Enum.at(log.log, 1)["type"] == "trans"
    end

    test_with_mock "ERROR send message near_client", Publit.OrganizationChannel, [],
      [broadcast_order: fn(_a, _b) -> :ok end] do

      Agent.start_link(fn -> [] end, name: :api_mock)

      org = insert(:organization)
      uc = insert(:user_client, %{extra_data: %{"device_token" => "nn"}})
      order = create_order_only(uc, org, %{status: "transporting"})

      {lng, lat} = order.client_pos.coordinates

      ut = insert(:user_transport, %{status: "order", pos: %Geo.Point{coordinates: {lng + 0.05, lat + 0.05}, srid: nil},
                orders: [%{"id" => order.id, "status" => "transporting"}] })

      lat = lat + 0.0001
      lng = lng - 0.0001
      pos = %{"coordinates" => [lng, lat], "type" => "Point"}

      ####################################
      assert {:ok, ut} = PosService.update_pos(ut, %{"pos" => pos})
      assert ut.pos == %Geo.Point{coordinates: {lng, lat}, srid: nil}

      token = uc.extra_data["device_token"]
      assert token

      #assert Publit.MessageApiMock.get_data() == %{}

      assert called Publit.OrganizationChannel.broadcast_order(:_, "order:near_client")

      ord = Repo.get(Order, order.id)
      assert ord.transport.delivered_arrived_at
    end
  end

end
