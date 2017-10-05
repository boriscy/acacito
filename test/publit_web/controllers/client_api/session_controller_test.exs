defmodule Publit.ClientApi.SessionControllerTest do
  use PublitWeb.ConnCase
  alias Publit.{UserClient, UserUtil}

  describe "POST /client_api/login" do
    test "OK", %{conn: conn} do
      {:ok, uc} = UserClient.create(%{mobile_number: "77112233", full_name: "Amaru Barroso"} )

      token = uc.mobile_verification_token

      conn = post(conn, "/client_api/login", %{"mobile_number" => "77112233"})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert json["user"]["id"]
      assert json["user"]["mobile_verification_token"]
      assert "C" <> _t = json["user"]["mobile_verification_token"]

      assert String.length(json["sms_gateway"]) == 8
    end

    test "not_found", %{conn: conn} do
      conn = post(conn, "/client_api/login", %{"mobile_number" => "77112233"})

       assert conn.status == Plug.Conn.Status.code(:not_found)
       json = Poison.decode!(conn.resp_body)

       assert json["error"] == gettext("Mobile number not found")
    end

  end

  describe "get_token" do
    test "OK", %{conn: conn} do
      {:ok, uc} = UserClient.create(%{mobile_number: "77112233", full_name: "Amaru Barroso"} )

      UserUtil.check_mobile_verification_token("77112233", uc.mobile_verification_token)

      conn = post(conn, "/client_api/get_token", %{auth: %{mobile_number: "77112233", token: uc.mobile_verification_token}})
      json = Poison.decode!(conn.resp_body)

      assert conn.status == Plug.Conn.Status.code(:ok)
      assert String.length(json["token"]) > 30
      assert json["user"]
    end

    test "Error", %{conn: conn} do
      {:ok, uc} = UserClient.create(%{mobile_number: "77112233", full_name: "Amaru Barroso"} )

      conn = post(conn, "/client_api/get_token", %{auth: %{mobile_number: "77112233", token: uc.mobile_verification_token}})

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
    end
  end

end
