defmodule Publit.TransApi.SessionControllerTest do
  use PublitWeb.ConnCase
  alias Publit.{UserTransport, UserAuthentication}

  setup do
    %{conn: build_conn()}
  end

  defp user do
    {:ok, u} = Repo.insert(%UserTransport{email: "juan@mail.com", mobile_number: "59177123456",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo4321"), verified: true} )
    u
  end

  describe "POST /trans_api/login" do
    test "OK", %{conn: conn} do
      user()
      conn = post(conn, "/trans_api/login", %{"login" => %{"mobile_number" => "59177123456", "password" => "demo4321"}})

       assert conn.status == 200
       json = Poison.decode!(conn.resp_body)

       assert json["token"]
       assert json["user"]["id"]
    end

    test "ERROR", %{conn: conn} do
      user()
      conn = post(conn, "/trans_api/login", %{"login" => %{"mobile_number" => "59177123456", "password" => "demo1234"}})

       assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
    end
  end

  describe "GET /trans_api/valid_token" do
    test "VALID", %{conn: conn} do
      ut = insert(:user_transport)
      token = UserAuthentication.encrypt_user_id(ut.id)

      conn = get(conn, "/trans_api/valid_token/#{token}")

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert json["user"]["id"] == ut.id
      assert json["token"]
    end

    test "INVALID", %{conn: conn} do
      id = Ecto.UUID.generate()
      token = UserAuthentication.encrypt_user_id(id) <> "aa"

      conn = get(conn, "/trans_api/valid_token/#{token}")

      assert conn.status == Plug.Conn.Status.code(:unauthorized)
      json = Poison.decode!(conn.resp_body)

      assert json["valid"] == false
    end

  end

end

