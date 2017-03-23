defmodule Publit.TransApi.RegistrationControllerTest do
  use Publit.ConnCase
  require Publit.Gettext

  setup do
    %{conn: build_conn() }
  end

  @valid_params %{
    "full_name" => "Amaru Barroso",
    "email" => "amaru@mail.com",
    "password"=> "demo1234",
    "vehicle" => "car",
    "plate" => "CAR-123",
    "mobile_number" => "73732655"}

  describe "POST /trans_api/registration" do
    test "OK", %{conn: conn} do
      conn = post(conn, "/trans_api/registration", %{"user" => @valid_params})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)
      assert json["token"]
      assert json["user"]["vehicle"] == "car"
      assert json["user"]["plate"] == "CAR-123"
    end

    test "ERROR",%{conn: conn} do
      conn = post(conn, "/trans_api/registration", %{"user" => %{"email" => "invalid@mail", "full_name" => "Juan Perez"} })

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      json = Poison.decode!(conn.resp_body)
      assert json["errors"]["email"]
      refute json["errors"]["full_name"]
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

