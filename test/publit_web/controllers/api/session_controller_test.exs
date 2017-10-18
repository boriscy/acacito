defmodule PublitWeb.Api.SessionControllerTest do
  use PublitWeb.ConnCase
  alias Publit.{UserClient, UserTransport, User}

  @cli_params %{"full_name" => "Amaru Barroso", "mobile_number" => "73732655"}
  @trans_params %{full_name: "Julio Juarez", mobile_number: "73732655", plate: "TUK123", vehicle: "motorcycle"}

  describe "verify_mobile_number" do
    test "user_client OK", %{conn: conn} do
      {:ok, uc} = UserClient.create(@cli_params)

      conn = post(conn, "/api/validate_token", %{"message" => uc.mobile_verification_token, "phone" => "73732655"})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      user = Repo.get(UserClient, json["user"]["id"])

      assert user.verified == true
      assert "VC" <> t = user.mobile_verification_token
      assert String.length(t) == 6
    end

    test "user_transport OK" do
      {:ok, ut} = UserTransport.create(@trans_params)

      conn = post(conn, "/api/validate_token", %{"message" => ut.mobile_verification_token, "phone" => "73732655"})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      user = Repo.get(UserTransport, json["user"]["id"])

      assert user.verified == true
      assert user.plate == "TUK123"
      assert "VT" <> t = user.mobile_verification_token
      assert String.length(t) == 6
    end

    test "invalid", %{conn: conn} do
      conn = post(conn, "/api/validate_token", %{"message" => "111", "phone" => "73732655"})

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)

      json = Poison.decode!(conn.resp_body)
      assert json["error"]
    end

  end
end
