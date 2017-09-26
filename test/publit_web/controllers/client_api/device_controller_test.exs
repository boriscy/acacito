defmodule Publit.ClientApi.DeviceControllerTest do
  use PublitWeb.ConnCase

  setup do
    uc = insert(:user_client)
    conn = build_conn()
    |> assign(:current_user_client, uc)

    %{conn: conn}
  end

  @device_token "14d14fa953ac53aaff8416"

  describe "PUT /cli_api/device" do
    test "OK", %{conn: conn} do
      conn = put(conn, "/client_api/device", %{"device_token" => @device_token})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert json["user"]["id"] == conn.assigns[:current_user_client].id
    end

    test "ERROR" do
      conn = build_conn()
      conn = put(conn, "/client_api/device", %{"device_token" => @device_token})

      assert conn.status == Plug.Conn.Status.code(:unauthorized)
      json = Poison.decode!(conn.resp_body)

      assert json["message"] == gettext("You need to login")
    end
  end

end


