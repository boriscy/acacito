defmodule Publit.ClientApi.SessionControllerTest do
  use Publit.ConnCase
  alias Publit.{UserClient, UserAuthentication}

  setup do
    %{conn: build_conn()}
  end

  describe "POST /client_api/login" do
    test "OK", %{conn: conn} do
      Repo.insert(%UserClient{email: "amaru@mail.com", mobile_number: "59177112233", encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo4321"), verified: true} )
      conn = post(conn, "/client_api/login", %{"login" => %{"email" => "amaru@mail.com", "password" => "demo4321"}})

       assert conn.status == 200
       json = Poison.decode!(conn.resp_body)

       assert json["token"]
       assert json["user"]["id"]
    end

    test "OK with mobile", %{conn: conn} do
      Repo.insert(%UserClient{email: "amaru@mail.com", mobile_number: "59177112233", encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo4321"), verified: true} )
      conn = post(conn, "/client_api/login", %{"login" => %{"email" => "59177112233", "password" => "demo4321"}})

       assert conn.status == 200
       json = Poison.decode!(conn.resp_body)

       assert json["token"]
       assert json["user"]["id"]
    end

    test "ERROR", %{conn: conn} do
      Repo.insert(%UserClient{email: "amaru@mail.com", mobile_number: "59177112233", encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo4321")} )
      conn = post(conn, "/client_api/login", %{"login" => %{"email" => "amaru@mail.com", "password" => "demo1234"}})

       assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
       json = Poison.decode!(conn.resp_body)

       assert json["errors"]["email"] == Gettext.dgettext(Publit.Gettext, "errors", "Invalid email or mobile number")
    end

    test "ERROR not verified", %{conn: conn} do
      Repo.insert(%UserClient{email: "amaru@mail.com", mobile_number: "59177112233", encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo4321"), verified: false} )
      conn = post(conn, "/client_api/login", %{"login" => %{"email" => "amaru@mail.com", "password" => "demo4321"}})

       assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
       json = Poison.decode!(conn.resp_body)

       assert json["errors"]["email"]
    end
  end

  describe "GET /client_api/valid_token" do
    test "VALID", %{conn: conn} do
      uc = insert(:user_client)
      token = UserAuthentication.encrypt_user_id(uc.id)

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
