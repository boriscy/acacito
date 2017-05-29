defmodule Publit.Order.CommentTest do
  use Publit.ModelCase
  alias Publit.{Order}

  describe "create client" do
    test "cli_org" do
      org = insert(:organization)
      cli = insert(:user_client)

      order = create_order_only(cli, org)
      params = %{"comment" => "My cli comment", "rating" => 3, "comment_type" => "cli_org"}

      assert {:ok, order, comment} = Order.Comment.create(order, cli, params)

      assert order.comment_details["cli_org"]
      assert order.comment_details["cli_org_rating"] == 3

      assert comment.comment == "My cli comment"
    end

    test "cli_trans" do
      org = insert(:organization)
      cli = insert(:user_client)
      trans = insert(:user_transport)

      order = create_order_only(cli, org, %{user_transport_id: trans.id})
      params = %{"comment" => "My cli comment", "rating" => 4, "comment_type" => "cli_trans"}

      assert {:ok, order, comment} = Order.Comment.create(order, cli, params)

      assert order.comment_details["cli_trans"]
      assert order.comment_details["cli_trans_rating"] == 4

      assert comment.comment == "My cli comment"
    end
  end

  describe "create org" do
    test "org_cli" do
      org = insert(:organization)
      cli = insert(:user_client)

      order = create_order_only(cli, org)
      params = %{"comment" => "My org comment", "rating" => 4, "comment_type" => "org_cli"}

      assert {:ok, order, comment} = Order.Comment.create(order, org, params)

      assert order.comment_details["org_cli"]
      assert order.comment_details["org_cli_rating"] == 4

      assert comment.comment == "My org comment"
    end

    test "org_trans" do
      org = insert(:organization)
      cli = insert(:user_client)
      trans = insert(:user_transport)

      order = create_order_only(cli, org, %{user_transport_id: trans.id})
      params = %{"comment" => "My org comment", "rating" => 4, "comment_type" => "org_trans"}

      assert {:ok, order, comment} = Order.Comment.create(order, org, params)

      assert order.comment_details["org_trans"]
      assert order.comment_details["org_trans_rating"] == 4

      assert comment.comment == "My org comment"
    end
  end

  describe "create trans" do
    test "trans_org" do
      org = insert(:organization)
      cli = insert(:user_client)
      trans = insert(:user_transport)

      order = create_order_only(cli, org, %{user_transport_id: trans.id})
      params = %{"comment" => "My trans comment", "rating" => 4, "comment_type" => "trans_org"}

      assert {:ok, order, comment} = Order.Comment.create(order, trans, params)

      assert order.comment_details["trans_org"]
      assert order.comment_details["trans_org_rating"] == 4

      assert comment.comment == "My trans comment"
    end

    test "trans_cli" do
      org = insert(:organization)
      cli = insert(:user_client)
      trans = insert(:user_transport)

      order = create_order_only(cli, org, %{user_transport_id: trans.id})
      params = %{"comment" => "My trans comment", "rating" => 3, "comment_type" => "trans_cli"}

      assert {:ok, order, comment} = Order.Comment.create(order, trans, params)

      assert order.comment_details["trans_cli"]
      assert order.comment_details["trans_cli_rating"] == 3

      assert comment.comment == "My trans comment"
    end

  end
end
