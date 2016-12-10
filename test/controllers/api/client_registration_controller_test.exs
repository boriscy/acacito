defmodule Publit.Api.ClientRegistrationControllerTest do
  use Publit.ConnCase
  require Publit.Gettext

  setup do
    %{conn: build_conn}
  end

  @valid_params %{
    "full_name" => "Amaru Barroso",
    "email" => "amaru@mail.com",
    "password"=> "demo1234",
    "mobile_number" => "73732655"}

  describe "POST /api/client_registration" do
    test "OK", %{conn: conn} do
      conn = post(conn, "/api/client_registration", %{"user" => @valid_params})

      assert conn.status == 200
      user = Poison.decode!(conn.resp_body)["user"]
    end

    test "ERROR",%{conn: conn} do
      conn = post(conn, "/api/client_registration", %{"user" => %{"email" => "invalid@mail", "full_name" => "Juan Perez"} })

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      json = Poison.decode!(conn.resp_body)
      assert json["errors"]["email"]
      refute json["errors"]["full_name"]
    end

  end
end

