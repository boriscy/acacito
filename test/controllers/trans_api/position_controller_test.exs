defmodule Publit.TransApi.PositionControllerTest do
  use PublitWeb.ConnCase
  import Mock

  setup do
    conn = build_conn()
    |> assign(:current_user_transport, insert(:user_transport))

    %{conn: conn}
  end

  describe "PUT /trans_api/position" do
    test_with_mock "OK", %{conn: conn}, PublitWeb.UserChannel, [],
      [broadcast_position: fn(u) ->
        assert %Publit.UserTransport{} = u
      end] do

      data = %{"altitude" => 1687, "pos" => %{"type" => "Point",
        "coordinates" => [-17.8145819, -63.1560853]},  "speed" => 23, "status" => "listen"}

      conn = put(conn, "/trans_api/position", %{"position" =>  data})

      json = Poison.decode!(conn.resp_body)
      user = conn.assigns[:current_user_transport]
      #assert called PublitWeb.UserChannel.broadcast_position(:_, "position")

      assert json["user"]["id"] == user.id
      assert json["user"]["mobile_number"] == user.mobile_number
      assert json["user"]["pos"] == %{"coordinates" => [-17.8145819, -63.1560853], "type" => "Point"}
      assert json["user"]["status"] == "listen"
    end

    test "ERROR", %{conn: conn} do
      conn = put(conn, "/trans_api/position", %{"position" => %{}})

      json = Poison.decode!(conn.resp_body)
      assert json["errors"]["pos"]
    end
  end

end
