defmodule Publit.TransApi.RegistrationControllerTest do
  use PublitWeb.ConnCase
  require PublitWeb.Gettext

  setup do
    %{conn: build_conn() }
  end

  @valid_params %{
    "full_name" => "Amaru Barroso",
    "vehicle" => "car",
    "plate" => "CAR-123",
    "mobile_number" => "73732655"}

  describe "POST /trans_api/registration" do
    test "OK", %{conn: conn} do
      conn = post(conn, "/trans_api/registration", %{"user" => @valid_params})

      json = Poison.decode!(conn.resp_body)

      assert conn.status == 200
      assert json["sms_gateway"]
      assert json["user"]["vehicle"] == "car"
      assert json["user"]["plate"] == "CAR-123"
    end

    test "ERROR",%{conn: conn} do
      conn = post(conn, "/trans_api/registration", %{"user" => %{"full_name" => ""} })

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)

      json = Poison.decode!(conn.resp_body)
      assert json["errors"]["full_name"]
      assert json["errors"]["vehicle"]
      assert json["errors"]["mobile_number"]
    end

    test "Error plate", %{conn: conn} do

      conn = post(conn, "/trans_api/registration", %{"user" => Map.merge(@valid_params, %{"plate" => ""}) })

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      json = Poison.decode!(conn.resp_body)
      assert json["errors"]["plate"]
    end

    test "OK bike", %{conn: conn} do
      params = %{
        "full_name" => "Amaru Barroso",
        "password"=> "demo1234",
        "vehicle" => "bike",
        "mobile_number" => "73732655"}

      conn = post(conn, "/trans_api/registration", %{"user" => params })

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert json["user"]["vehicle"] == "bike"
    end
  end
end

