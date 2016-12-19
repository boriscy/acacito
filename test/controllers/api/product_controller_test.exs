defmodule Publit.Api.ProductControllerTest do
  use Publit.ConnCase
  alias Publit.{User, Product}

  setup do
    conn = build_conn
    |> assign(:current_user, %User{full_name: "Amaru", id: "781d55f4-e055-4098-a0f5-fd4852db8db0"})

    %{conn: conn}
  end


  describe "GET /api/:organization_id/products" do
    test "OK", %{conn: conn} do
      org = insert(:organization)
      create_products(org)

      conn = get(conn, "/api/#{org.id}/products")

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)
      assert json["products"] |> Enum.count() == 3
    end
  end
end
