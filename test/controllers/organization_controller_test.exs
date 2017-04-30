defmodule Publit.OrganizationControllerTest do
  use Publit.ConnCase

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

  describe "PUT /organizations/:id" do
    test "OK html", %{conn: conn} do
      conn = put(conn, "/organizations/current", %{"organization" => %{
         "name" => "Other org name", "mobile_number" => "59176543210",
         "pos" => %{"coordinates" => [10, 10], "type" => "Point"} } })

      assert redirected_to(conn) == "/organizations/#{conn.assigns.current_organization.id}"
    end

    test "ERROR html", %{conn: conn} do
      conn = put(conn, "/organizations/current", %{"organization" => %{
         "name" => "" } })

      assert view_template(conn) == "edit.html"
    end

    test "OK json", %{conn: conn} do
      conn = put(conn, "/organizations/current", %{"organization" => %{
        "mobile_number" => "59176543210",
         "pos" => %{"coordinates" => ["-120", "30"], "type" => "Point"} }, "format" => "json" })

      org = Poison.decode!(conn.resp_body)
      assert org["organization"]["mobile_number"] == "59176543210"
      assert org["organization"]["pos"] == %{"coordinates" => ["-120", "30"], "type" => "Point"}
    end

    test "ERROR json", %{conn: conn} do
      conn = put(conn, "/organizations/current", %{"organization" => %{
         "pos" => %{"lat" => "30", "lng" => "-190"}, "name" => "" }, "format" => "json" })

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
    end
  end

  describe "PUT /organization/open_close" do
    test "open", %{conn: conn} do
      conn = put(conn, "/organizations/open_close")

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
end
