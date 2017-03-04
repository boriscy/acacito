defmodule PublitPosServiceTest do
  use Publit.ModelCase
  import Mock
  alias Publit.PosService
  require Publit.Gettext
  import Publit.Gettext

  describe "update_position" do
    test "OK" do
      pos = %{"coordinates" => [-17.8145819, -63.1560853], "type" => "Point"}
      user = insert(:user_transport)

      assert user.pos == nil

      assert {:ok, user} = PosService.update_pos(user, %{"pos" => pos, "speed" => 30})

      assert user.pos == %Geo.Point{coordinates: {-17.8145819, -63.1560853}, srid: nil}
      assert user.status == "listen"
    end

    test "invalid" do
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

      #Agent.start_link(fn -> %{} end, name: :api_mock)

      org = insert(:organization)
      uc = insert(:user_client)
      order = create_order_only(uc, org)

      {lng, lat} = order.organization_pos.coordinates

      ut = insert(:user_transport, %{status: "order", pos: %Geo.Point{coordinates: {lng + 0.05, lat + 0.05}, srid: nil},
                orders: [%{"order_id" => order.id, "status" => "transport",
                "client_pos" => Geo.JSON.encode(order.client_pos), "organization_pos" => Geo.JSON.encode(order.organization_pos) }] })

      pos = %{"coordinates" => [lng + 0.001, lat + 0.001], "type" => "Point"}

      assert {:ok, ut} = PosService.update_pos(ut, %{"pos" => pos})
      assert ut.pos == %Geo.Point{coordinates: {-18.179, -63.869}, srid: nil}

      token = uc.extra_data["fb_token"]
      assert token
      #IO.inspect Agent.get(:api_mock, fn(v)-> v end)
      #Publit.MessageApiMock.get_data()
      #== %{message: %{status: "order:near_org"}, tokens: [token]}

      assert called Publit.OrganizationChannel.broadcast_order(:_, "order:near_org")
    end


    test_with_mock "OK near_client", Publit.OrganizationChannel, [],
      [broadcast_order: fn(_a, _b) -> :ok end] do

      Agent.start_link(fn -> %{} end, name: :api_mock)

      org = insert(:organization)
      uc = insert(:user_client)
      order = create_order_only(uc, org)

      {lng, lat} = order.client_pos.coordinates

      ut = insert(:user_transport, %{status: "order", pos: %Geo.Point{coordinates: {lng + 0.05, lat + 0.05}, srid: nil},
                orders: [%{"order_id" => order.id, "status" => "transporting",
                "client_pos" => Geo.JSON.encode(order.client_pos), "organization_pos" => Geo.JSON.encode(order.organization_pos) }] })


      lat = lat + 0.001
      lng = lng + 0.001
      pos = %{"coordinates" => [lng, lat], "type" => "Point"}

      assert {:ok, ut} = PosService.update_pos(ut, %{"pos" => pos})
      assert ut.pos == %Geo.Point{coordinates: {lng, lat}, srid: nil}

      token = uc.extra_data["fb_token"]
      assert token

      assert Publit.MessageApiMock.get_data() == %{msg: %{
        title: gettext("Transport near"), message: gettext("Your order is arriving"),
        status: "order:near_client"}, tokens: [token]}

      assert called Publit.OrganizationChannel.broadcast_order(:_, "order:near_client")
    end
  end

end
