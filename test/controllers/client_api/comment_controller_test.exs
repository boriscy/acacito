defmodule Publit.ClientApi.OrderControllerTest do
  use Publit.ConnCase
  require Publit.Gettext
  import Publit.Gettext
  alias Publit.{Order}

  setup do
    user_client = insert(:user_client)
    org = insert(:organization)
    conn = build_conn()
    |> assign(:current_user_client, user_client)

    %{conn: conn, user_client: user_client, org: org}
  end
  defp salt, do: Application.get_env(:publit, Publit.Endpoint)[:secret_key_base]

  describe "POST /client_api/comments" do
    test "OK cli", %{conn: conn, user_client: uc, org: org} do
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
      conn2 = conn

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

      conn = post(conn2, "/client_api/comments", params)

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)

      json = Poison.decode!(conn.resp_body)

      assert json["error"] == gettext("Comment done")
    end

    test "not found", %{conn: conn} do
      params = %{"comment" => %{"order_id" => Ecto.UUID.generate(), "rating" => 3,
        "comment_type" => "cli_trans", "comment" => "This is a trans comment"}}

      conn = post(conn, "/client_api/comments", params)

      assert conn.status == 404
    end

    test "comments", %{conn: conn, user_client: uc, org: org} do
      u_trans = insert(:user_transport)

      order = create_order_only(uc, org, %{status: "delivered", user_transport_id: u_trans.id})
      c_cli = insert(:comment, %{order_id: order.id, comment_type: "cli_org", from_id: uc.id, to_id: org.id})
      c_trans = insert(:comment, %{order_id: order.id, comment_type: "cli_trans", from_id: uc.id, to_id: u_trans.id})

      conn = get(conn, "/client_api/comments/#{order.id}/comments")

      assert conn.status == 200

      json = Poison.decode!(conn.resp_body)

      assert Enum.count(json["comments"]) == 2
      assert Enum.map(json["comments"], fn(v) -> v["order_id"] end) == [order.id, order.id]
    end

  end

  describe "PUT /client_api/comments/:id" do
    test "OK", %{conn: conn, user_client: cli, org: org} do
      order = create_order_only(cli, org, %{status: "delivered"})
      params = %{"comment" => "My org comment", "rating" => 3, "comment_type" => "cli_org"}

      assert {:ok, res} = Order.Comment.create(order, cli, params)

      params = %{"comment" => "My updated org comment", "rating" => 5}

      conn = put(conn, "/client_api/comments/#{res.comment.id}", %{"comment" => params})

      assert conn.status == 200

      json = Poison.decode!(conn.resp_body)

      assert json["order"]["comment_details"]["cli_org_rating"] == 5
    end

    test "not_found", %{conn: conn} do
      params = %{"comment" => "My updated org comment", "rating" => 5}

      conn = put(conn, "/client_api/comments/#{Ecto.UUID.generate()}", %{"comment" => params})
    end

    test "error", %{conn: conn, user_client: cli, org: org} do
      order = create_order_only(cli, org, %{status: "delivered"})
      params = %{"comment" => "My org comment", "rating" => 3, "comment_type" => "cli_org"}

      assert {:ok, res} = Order.Comment.create(order, cli, params)

      params = %{"comment" => "My updated org comment", "rating" => 0}

      conn = put(conn, "/client_api/comments/#{res.comment.id}", %{"comment" => params})

      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)

      json = Poison.decode!(conn.resp_body)

      assert json["errors"]["rating"]
    end
  end

end
