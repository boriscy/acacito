defmodule Publit.TransApi.OrderControllerTest do
  use Publit.ConnCase

  alias Publit.{OrderCall}

  setup do
    ut = insert(:user_transport)

    conn = build_conn() |> assign(:current_user_transport, ut)

    %{conn: conn, ut: ut}
  end


  defp create_order_call(order) do
    Repo.insert(%OrderCall{})
  end


  describe "PUT /trans_api/accept/:order_id" do
    test "OK", %{conn: conn} do
      org = insert(:organization)
      uc = insert(:user_client)
      order = create_order(uc, org)

      oc = create_order_call(order)

      conn = put(conn, "/trans_api/accept/#{order.id}", %{"order_call_id" => oc.id})

      json = Poison.decode!(conn.resp_body)

      assert json["order"]["status"] == "transport"
    end
  end

end
