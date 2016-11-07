defmodule Publit.SessionControllerTest do
  use Publit.ConnCase
  alias Publit.{UserAuth}

  setup do
    user = insert(:user)
    conn = build_conn

    %{conn: conn, user: user}
  end

  describe "GET /login" do
    test "OK", %{conn: conn} do
      conn = get(conn, "/login")

      assert conn.assigns.changeset == %UserAuth{}
      assert conn.private.phoenix_action == :index
      assert conn.private.phoenix_controller == Publit.SessionController
    end
  end

  describe "POST /login" do
    test "OK", %{conn: conn, user: user} do
      conn = conn
      |> post("/login", %{"user" => %{"email" => "amaru@mail.com", "password" => "demo1234"} })

      assert redirected_to(conn) == "/store"
      {:ok, user_id} = Phoenix.Token.verify(Publit.Endpoint, "user_id", conn.private.plug_session["user_id"])

      assert user_id == user.id
    end

    test "Error", %{conn: conn, user: user} do
      conn = conn
      |> post("/login", %{"user" => %{"email" => "amaru@mail.com", "password" => "demo12"} })

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      assert conn.private.phoenix_flash["error"]
    end
  end

  describe "logout" do

  end
end
