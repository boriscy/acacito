defmodule Publit.ClientApi.SessionControllerTest do
  use Publit.ConnCase
  alias Publit.{UserClient, UserAuthentication}

  setup do
    %{conn: build_conn()}
  end

  describe "POST /client_api/login" do
    test "OK", %{conn: conn} do
      Repo.insert(%UserClient{email: "amaru@mail.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo4321")} )
      conn = post(conn, "/client_api/login", %{"login" => %{"email" => "amaru@mail.com", "password" => "demo4321"}})

       assert conn.status == 200
       json = Poison.decode!(conn.resp_body)

       assert json["token"]
       assert json["user"]["id"]
    end

    test "ERROR", %{conn: conn} do
      Repo.insert(%UserClient{email: "amaru@mail.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo4321")} )
      conn = post(conn, "/client_api/login", %{"login" => %{"email" => "amaru@mail.com", "password" => "demo1234"}})

       assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
    end
  end

  describe "GET /client_api/valid_token" do
    test "VALID", %{conn: conn} do
      id = Ecto.UUID.generate()
      token = UserAuthentication.encrypt_user_id(id)

      conn = get(conn, "/client_api/valid_token/#{token}")

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert json["valid"] == true
    end

    test "INVALID", %{conn: conn} do
      id = Ecto.UUID.generate()
      token = UserAuthentication.encrypt_user_id(id) <> "aa"

      conn = get(conn, "/client_api/valid_token/#{token}")

      assert conn.status == Plug.Conn.Status.code(:unauthorized)
      json = Poison.decode!(conn.resp_body)

      assert json["valid"] == false
    end

  end

end
