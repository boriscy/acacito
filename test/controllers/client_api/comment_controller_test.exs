defmodule Publit.ClientApi.OrderControllerTest do
  use Publit.ConnCase
  require Publit.Gettext

  setup do
    user_client = insert(:user_client)
    org = insert(:organization)
    conn = build_conn()
    |> assign(:current_user_client, user_client)

    %{conn: conn, user_client: user_client, org: org}
  end
  defp salt, do: Application.get_env(:publit, Publit.Endpoint)[:secret_key_base]

  describe "POST /client_api/comments" do
    test "OK", %{conn: conn, user_client: uc, org: org} do
      order = create_order_only(uc, org, %{status: "delivered"})

      params = %{"comment" => %{"order_id" => order.id, "rating" => 4,
        "comment_type" => "cli_org", "comment" => "This is a org comment"}}

      conn = post(conn, "/client_api/comments", params)

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      comment = json["comment"]
      assert comment["rating"] == 4
      assert comment["comment"] == "This is a org comment"
      assert comment["comment_type"] == "cli_org"

      order = json["order"]
      assert order["comment_details"]["cli_org"]
      assert order["comment_details"]["cli_org_rating"] == 4
    end

    test "OK trans", %{conn: conn, user_client: uc, org: org} do
      order = create_order_only(uc, org, %{status: "delivered"})

      params = %{"comment" => %{"order_id" => order.id, "rating" => 3,
        "comment_type" => "cli_trans", "comment" => "This is a trans comment"}}

      conn = post(conn, "/client_api/comments", params)

      json = Poison.decode!(conn.resp_body)
      assert conn.status == 200

      comment = json["comment"]
      assert comment["rating"] == 3
      assert comment["comment"] == "This is a trans comment"
      assert comment["comment_type"] == "cli_trans"

      order = json["order"]
      assert order["comment_details"]["cli_trans"]
      assert order["comment_details"]["cli_trans_rating"] == 3
    end

    #test "unauthorized" do
    #  conn = build_conn() |> put_req_header("user_token", Phoenix.Token.sign(Endpoint, salt(), Ecto.UUID.generate()))

    #  conn = post(conn, "/client_api/orders", %{"order" => %{}})

    #  assert conn.status == Plug.Conn.Status.code(:unauthorized)
    #  json = Poison.decode!(conn.resp_body)

    #  assert json["message"] == Publit.Gettext.gettext("You need to login")
    #end
  end

end
