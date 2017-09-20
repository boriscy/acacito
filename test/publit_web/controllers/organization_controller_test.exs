defmodule Publit.OrganizationControllerTest do
  use PublitWeb.ConnCase

  defp user_conn do
    {user, _org} = create_user_org(%{mobile_number: "59166778899"})
    build_conn() |> assign(:current_user, user)
  end

  setup do
    conn = build_conn()
    |> set_user_org_conn(%{email: "other@mail.com"})

    %{conn: conn}
  end

  describe "GET /organizations" do
    test "OK" do
      conn = user_conn() |> get("/organizations")

      assert conn.status == 200
      assert view_template(conn) == "index.html"
      assert Enum.count(conn.assigns.organizations) == 1
    end
  end

  describe "PUT /organization/open_close" do
    test "open", %{conn: conn} do
      conn = put(conn, "/organizations/open_close", %{"organization" => %{} })

      json = Poison.decode!(conn.resp_body)

      assert conn.status == 200
      assert json["organization"]["open"] == true
    end

    test "close", %{conn: conn} do
      {:ok, org} = Publit.Organization.open_close(conn.assigns.current_organization, conn.assigns.current_user.id)
      assert org.open == true
      conn = assign(conn, :current_organization, org)

      conn = put(conn, "/organizations/open_close")

      json = Poison.decode!(conn.resp_body)

      assert conn.status == 200
      assert json["organization"]["open"] == false
    end
  end

  describe "GET /organizations/current/edit_images" do
    test "OK", %{conn: conn} do
      conn = get(conn, "/organizations/images")

      assert conn.status == 200
      assert view_template(conn) == "images.html"
    end
  end
end
