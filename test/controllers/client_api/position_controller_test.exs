defmodule Publit.ClientApi.PositionControllerTest do
  use Publit.ConnCase, async: false

  @pos %Geo.Point{coordinates: { -63.8748, -18.1778 }, srid: nil}

  setup do
    uc = insert(:user_client)
    conn = build_conn()
    |> assign(:current_user_client, uc)

    %{conn: conn, uc: uc}
  end

  describe "GET /client_api/user_transport_position" do
    test "OK", %{conn: conn} do
      ut = insert(:user_transport, pos: @pos)

      conn = conn |> get("/client_api/user_transport_position/#{ut.id}")

      json = Poison.decode!(conn.resp_body)

      assert conn.status == 200

      assert json["user"]["mobile_number"] == ut.mobile_number
      {lng, lat} = @pos.coordinates
      assert json["user"]["pos"]["coordinates"] == [lng, lat]
    end

    test "User not found",%{conn: conn} do
      conn = conn |> get("/client_api/user_transport_position/e505fde3-c38c-488b-8541-ca24491099bd")

      assert conn.status == 404
    end
  end
end
