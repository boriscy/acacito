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
    ] |> Enum.map(fn(ut) -> Repo.insert(ut) end)
  end

  defp order do
   %Order{id: Ecto.UUID.generate(), organization_pos: %Geo.Point{coordinates: { -63.8748, -18.1778 }, srid: nil} }
  end

  describe "create" do
    test "OK" do
      org = insert(:organization, pos: %Geo.Point{coordinates: { -63.8748, -18.1778 }, srid: nil})
      uc = insert(:user_client)
      create_user_transports()
      {:ok, ord} = Repo.insert(Map.merge(order(), %{organization_id: org.id, user_client_id: uc.id}))

      assert {:ok, oc, pid} = OrderCall.create(ord, org)

      assert oc.status == "new"
      assert Enum.count(oc.transport_ids) == 4

      ref = Process.monitor(pid)

      #Process.sleep(200)
      #  IO.inspect Repo.get(OrderCall, oc.id)
      receive do
        {:DOWN, ^ref, _, _, _} ->
          oc = Repo.get(OrderCall, oc.id)
          assert oc.status == "delivered"
          body = Poison.decode!(oc.resp["body"])
          assert body["success"] == 1
          assert oc.resp["headers"]
      end
    end
  end

  describe "get_transport_ids" do
    test "OK" do
      create_user_transports()
      trs = OrderCall.get_user_transports(%{"coordinates" => [-63.8748, -18.1778]})

      assert Enum.count(trs) == 4
    end
  end

end
