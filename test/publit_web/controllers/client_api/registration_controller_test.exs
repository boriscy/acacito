defmodule Publit.ClientApi.RegistrationControllerTest do
  use PublitWeb.ConnCase
  alias Publit.{UserClient, Repo}
  require PublitWeb.Gettext

  @valid_params %{"full_name" => "Amaru Barroso", "mobile_number" => "73732655"}

  describe "POST /client_api/registration" do
    test "OK", %{conn: conn} do
      Agent.start_link(fn -> %{} end, name: :sms_mock)

      conn = post(conn, "/client_api/registration", %{"user" => @valid_params})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert json["user"]
      assert json["user"]["mobile_verification_token"]
      assert json["user"]["mobile_verification_send_at"]
    end

    test "ERROR",%{conn: conn} do
      conn = post(conn, "/client_api/registration", %{"user" => %{"mobile_number" => "numfalse", "full_name" => "Ju"} })

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      json = Poison.decode!(conn.resp_body)
      assert json["errors"]["full_name"]
      assert json["errors"]["mobile_number"]
    end
  end


end
