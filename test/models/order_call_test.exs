defmodule Publit.OrderCallTest do
  use Publit.ModelCase
  alias Publit.{UserTransport, OrderCall, Order}

  defp create_user_transports do
    [
      %UserTransport{mobile_number: "11223344", status: "listen", pos: %Geo.Point{coordinates: {-63.876047,-18.1787804}, srid: nil},
      extra_data: %{fb_token: "11223344"}},
      %UserTransport{mobile_number: "22334455", status: "listen", pos: %Geo.Point{coordinates: {-63.8732718,-18.1767489}, srid: nil},
      extra_data: %{fb_token: "22334455"}},
      %UserTransport{mobile_number: "33445566", status: "listen", pos: %Geo.Point{coordinates: {-63.8210238,-18.1650556}, srid: nil},
      extra_data: %{fb_token: "33445566"}},
      %UserTransport{mobile_number: "44556677", status: "listen", pos: %Geo.Point{coordinates: {-63.8660898,-18.1781923}, srid: nil},
      extra_data: %{fb_token: "44556677"}},
      %UserTransport{mobile_number: "55667788", status: "listen", pos: %Geo.Point{coordinates: {-63.8732718,-18.1767489}, srid: nil},
      extra_data: %{fb_token: "55667788"}}
    ] |> Enum.map(&Repo.insert/1)
  end

  defp order do
   %Order{id: Ecto.UUID.generate(),
      organization_pos: %Geo.Point{coordinates: { -63.8748, -18.1778 }, srid: nil},
      client_pos: %Geo.Point{coordinates: { -63.8749, -18.1779 }, srid: nil} }
  end

  describe "create" do
    test "OK" do
      org = insert(:organization, pos: %Geo.Point{coordinates: { -63.8748, -18.1778 }, srid: nil})
      uc = insert(:user_client)
      create_user_transports()
      {:ok, ord} = Repo.insert(Map.merge(order(), %{organization_id: org.id, user_client_id: uc.id}))

      assert {:ok, oc, pid} = OrderCall.create(ord)

      assert oc.status == "new"
      assert Enum.count(oc.transport_ids) == 4

      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, _, _, _} ->
          oc = Repo.get(OrderCall, oc.id)
          assert oc.status == "delivered"
          body = Poison.decode!(oc.resp["body"])
          assert body["success"] == 1
          assert oc.resp["headers"]
      end
    end

    test "ERROR" do
      org = insert(:organization, pos: %Geo.Point{coordinates: { -63.8748, -18.1778 }, srid: nil})
      uc = insert(:user_client)
      [
        %UserTransport{mobile_number: "11223344", status: "listen", pos: %Geo.Point{coordinates: {-63.876047,-18.1787804}, srid: nil},
        extra_data: %{fb_token: "11223344"}},
        %UserTransport{mobile_number: "22334455", status: "listen", pos: %Geo.Point{coordinates: {-63.8732718,-18.1767489}, srid: nil},
        extra_data: %{fb_token: "223344"}}
      ]
      |> Enum.map(&Repo.insert/1)

      {:ok, ord} = Repo.insert(Map.merge(order(), %{organization_id: org.id, user_client_id: uc.id}))

      assert {:ok, oc, pid} = OrderCall.create(ord)

      ref = Process.monitor(pid)

      receive do
        {:DOWN, ^ref, _, _, _} ->
          oc = Repo.get(OrderCall, oc.id)

          assert oc.status == "error"
          body = Poison.decode!(oc.resp["body"])
          assert body["failure"] == 1
          assert body["success"] == 0
      end
    end

    test "empty set " do
      org = insert(:organization, pos: %Geo.Point{coordinates: { -63.8748, -18.1778 }, srid: nil})
      uc = insert(:user_client)
      {:ok, ord} = Repo.insert(Map.merge(order(), %{organization_id: org.id, user_client_id: uc.id}))

      assert {:empty, oc} = OrderCall.create(ord)
      assert oc.transport_ids == []
    end

  end

  describe "get_transport_ids" do
    test "OK" do
      create_user_transports()
      trs = OrderCall.get_user_transports(%{"coordinates" => [-63.8748, -18.1778]})

      assert Enum.count(trs) == 4
    end
  end

  describe "encode" do
    test "OK" do
      uc = insert(:user_client)
      org = insert(:organization)

      ord = create_order(uc, org)

      {:ok, oc} = Repo.insert(%OrderCall{transport_ids: [Ecto.UUID.generate()], status: "new", order_id: ord.id })
      oc = Map.put(oc, :order, ord)

      assert {:ok, json} = OrderCall.encode(oc) |> Poison.encode()

      json = Poison.decode!(json)
      assert json["id"] == oc.id
      assert json["order"]["id"] == ord.id
      assert json["order"]["total"] == Decimal.to_string(ord.total)
    end
  end

end