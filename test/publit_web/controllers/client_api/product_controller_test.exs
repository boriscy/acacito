defmodule Publit.ClientApi.ProductControllerTest do
  use PublitWeb.ConnCase
  alias Publit.{UserClient}

  setup do
    conn = build_conn()

    %{conn: conn}
  end


  describe "GET /api/:organization_id/products" do
    test "OK", %{conn: conn} do
      org = insert(:organization)
      create_products(org)

      conn = get(conn, "/client_api/#{org.id}/products")

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)
      assert json["products"] |> Enum.count() == 3
    end
  end
end
