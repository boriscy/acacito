defmodule Publit.SessionControllerTest do
  use Publit.ConnCase
  alias Publit.{UserOrganization}

  setup do
    org = insert(:organization)
    user = insert(:user, organizations: [%UserOrganization{
      organization_id: org.id, name: org.name
    }])

    conn = build_conn()

    %{conn: conn, user: user, org: org}
  end

  describe "GET /login" do
    test "OK", %{conn: conn} do
      conn = get(conn, "/login")

      assert conn.assigns.changeset
      assert conn.assigns.valid == true
      assert conn.private.phoenix_action == :index
      assert conn.private.phoenix_controller == Publit.SessionController
    end
  end

  describe "POST /login" do
    test "OK", %{conn: conn, user: user, org: org} do
      conn = conn
      |> post("/login", %{"user_authentication" => %{"email" => "lucas@mail.com", "password" => "demo1234"} })

      assert redirected_to(conn) == "/dashboard"
      {:ok, user_id} = Phoenix.Token.verify(Publit.Endpoint, "user_id", get_session(conn, "user_id"))

      assert user_id == user.id
      {:ok, org_id} = Phoenix.Token.verify(Publit.Endpoint, "organization_id", get_session(conn, "organization_id"))

      assert org_id == org.id
    end

    test "OK no active organizations" do
      user = insert(:user, email: "other@mail.com", mobile_number: "99887766")

      conn = build_conn()
      |> post("/login", %{"user_authentication" => %{"email" => "other@mail.com", "password" => "demo1234"} })

      assert redirected_to(conn) == "/organizations"
      {:ok, u_id} = Phoenix.Token.verify(Publit.Endpoint, "user_id", get_session(conn, "user_id"))

      assert u_id == user.id
    end

    test "Error", %{conn: conn} do
      conn = conn
      |> post("/login", %{"user_authentication" => %{"email" => "amaru@mail.com", "password" => "demo12"} })

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
      assert conn.private.phoenix_flash["error"]
    end
  end

  describe "logout" do
    test "OK no active organizations" do
      user = insert(:user, email: "other@mail.com", mobile_number: "99887766")

      conn = build_conn()
      |> post("/login", %{"user_authentication" => %{"email" => "other@mail.com", "password" => "demo1234"} })

      assert redirected_to(conn) == "/organizations"
      {:ok, u_id} = Phoenix.Token.verify(Publit.Endpoint, "user_id", get_session(conn, "user_id"))

      assert u_id == user.id

      assert get_session(conn, "user_id")

      conn = delete(conn, "/logout")

      refute get_session(conn, "user_id")

      assert redirected_to(conn) == "/login"
    end
  end
end
