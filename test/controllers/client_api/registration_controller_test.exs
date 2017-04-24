defmodule Publit.ClientApi.RegistrationControllerTest do
  use Publit.ConnCase
  alias Publit.{UserClient, Repo}
  require Publit.Gettext

  setup do
    %{conn: build_conn() }
  end

  @valid_params %{
    "full_name" => "Amaru Barroso",
    "email" => "amaru@mail.com",
    "password"=> "demo1234",
    "mobile_number" => "59173732655"}

  describe "POST /client_api/registration" do
    test "OK", %{conn: conn} do
      Agent.start_link(fn -> %{} end, name: :sms_mock)

      conn = post(conn, "/client_api/registration", %{"user" => @valid_params})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert json["user"]
      refute json["token"]
    end

    test "ERROR",%{conn: conn} do
      conn = post(conn, "/client_api/registration", %{"user" => %{"email" => "invalid@mail", "full_name" => "Juan Perez"} })

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      json = Poison.decode!(conn.resp_body)
      assert json["errors"]["email"]
      refute json["errors"]["full_name"]
    end
  end

  describe "verification" do
    test "register and validate OK", %{conn: conn} do
      Agent.start_link(fn -> %{} end, name: :sms_mock)

      conn = post(conn, "/client_api/registration", %{"user" => @valid_params})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)
      json["user"]

      user = Repo.get(UserClient, json["user"]["id"])

      ver_code = Publit.AES.decrypt(user.extra_data["mobile_number_key"])

      conn = put(conn, "/client_api/validate_mobile_number/#{user.id}",
        %{"verification_code" => ver_code})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert json["user"]
      assert json["token"]
    end

    test "invalid number", %{conn: conn} do
      Agent.start_link(fn -> %{} end, name: :sms_mock)

      conn = post(conn, "/client_api/registration", %{"user" => @valid_params})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)
      json["user"]

      conn = put(conn, "/client_api/validate_mobile_number/#{json["user"]["id"]}",
        %{"verification_code" => "000"})

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      json = Poison.decode!(conn.resp_body)

      assert json["error"] == gettext("Invalid verification code")
    end

    test "verified code", %{conn: conn} do
      Agent.start_link(fn -> %{} end, name: :sms_mock)

      user = insert(:user_client, verified: true)

      conn = put(conn, "/client_api/validate_mobile_number/#{user.id}",
        %{"verification_code" => "123456"})

      assert conn.status == Plug.Conn.Status.code(:precondition_required)
      json = Poison.decode!(conn.resp_body)

      assert json["error"] == gettext("The mobile number has been verified")
    end
  end

  describe "resend_verication_number" do
    test "OK", %{conn: conn} do
      Agent.start_link(fn -> %{sleep_time: 5} end, name: :sms_mock)

      user = insert(:user_client)

      conn = put(conn, "/client_api/resend_verification_code/#{user.id}", %{"mobile_number" => "59166554433"})

      assert conn.status == 200

      Process.sleep(10)
      user = Repo.get(UserClient, user.id)

      m = Agent.get(:sms_mock, fn(v) -> v end)

      [[code]] = Regex.scan(~r/\d+/, m[:msg])
      assert Publit.AES.decrypt(user.extra_data["mobile_number_key"]) == code
    end

    test "error", %{conn: conn} do
      Agent.start_link(fn -> %{sleep_time: 5, status: "9"} end, name: :sms_mock)
      user = insert(:user_client)

      conn = put(conn, "/client_api/resend_verification_code/#{user.id}", %{"mobile_number" => "5916655443"})

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      json = Poison.decode!(conn.resp_body)

      assert json["errors"]["mobile_number"]
    end
  end
end
