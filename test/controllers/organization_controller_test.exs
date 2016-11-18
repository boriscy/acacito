defmodule Publit.OrganizationControllerTest do
  use Publit.ConnCase

  alias Publit.{Organization, Repo, UserOrganization}

  #def user_conn do
  #  user = insert(:user, organizations: [
  #    %UserOrganization{name: "Test", organization_id: Ecto.UUID.generate(), active: true},
  #    %UserOrganization{name: "Other", organization_id: Ecto.UUID.generate(), active: false}
  #  ])
  #  conn = build_conn
  #  |> assign(:current_user, user)
  #end

  defp user_conn do
    {user, _org} = create_user_org()
    build_conn |> assign(:current_user, user)
  end

  setup do
    conn = build_conn
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
         "name" => "Other org name" } })
    end

    test "OK", %{conn: conn} do
      conn = put(conn, "/organizations/current", %{"organization" => %{
         "geom" => %{"lat" => "30", "lng" => "-120"} } })

      org = Poison.decode!(conn.resp_body)
      assert org["organization"]["coords"] == %{"lat" => "30", "lng"=> "-120"}
    end
  end
end
