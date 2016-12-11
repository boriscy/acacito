defmodule Publit.Api.LoginControllerTest do
  use Publit.ConnCase
  alias Publit.{UserClient}


  setup do
    %{conn: build_conn()}
  end

  describe "POST /api/login" do
    test "OK", %{conn: conn} do
      Repo.insert(%UserClient{email: "amaru@mail.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo4321")} )
      conn = post(conn, "/api/login", %{"login" => %{"email" => "amaru@mail.com", "password" => "demo4321"}})

       assert conn.status == 200
       json = Poison.decode!(conn.resp_body)

       assert json["token"]
       assert json["user"]["id"]
    end

    test "ERROR", %{conn: conn} do
      Repo.insert(%UserClient{email: "amaru@mail.com", encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo4321")} )
      conn = post(conn, "/api/login", %{"login" => %{"email" => "amaru@mail.com", "password" => "demo1234"}})

       assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
    end
  end

end
