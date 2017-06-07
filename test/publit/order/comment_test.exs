defmodule Publit.Order.CommentTest do
  use Publit.ModelCase
  alias Publit.{Order}
  import Publit.Gettext

  describe "create client" do
    test "errors" do
      org = insert(:organization)
      cli = insert(:user_client)

      order = create_order_only(cli, org)
      params = %{"comment" => "My cli comment", "rating" => nil, "comment_type" => "cli_org"}

      assert {:error, error} = Order.Comment.create(order, cli, params)

      assert error == gettext("Invalid rating")
    end

    test "cli_org" do
      org = insert(:organization)
      cli = insert(:user_client)

      order = create_order_only(cli, org)
      params = %{"comment" => "My cli comment", "rating" => 3, "comment_type" => "cli_org"}

      assert {:ok, res} = Order.Comment.create(order, cli, params)

      comment = res.comment
      order = res.order

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

      assert {:ok, res} = Order.Comment.create(order, cli, params)
      comment = res.comment
      order = res.order

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

      assert {:ok, res} = Order.Comment.create(order, org, params)
      comment = res.comment
      order = res.order

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

      assert {:ok, res} = Order.Comment.create(order, org, params)
      comment = res.comment
      order = res.order

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

      assert {:ok, res} = Order.Comment.create(order, trans, params)
      comment = res.comment
      order = res.order

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

      assert {:ok, res} = Order.Comment.create(order, trans, params)
      comment = res.comment
      order = res.order

      assert order.comment_details["trans_cli"]
      assert order.comment_details["trans_cli_rating"] == 3

      assert comment.comment == "My trans comment"
    end

  end

  describe "update" do
    test "cli" do
      org = insert(:organization)
      cli = insert(:user_client)

      order = create_order_only(cli, org, %{status: "delivered"})
      params = %{"comment" => "My org comment", "rating" => 3, "comment_type" => "cli_org"}

      assert {:ok, res} = Order.Comment.create(order, cli, params)

      params = %{"comment" => "My updated comment", "rating" => 4}

      assert {:ok, res} = Order.Comment.update(res.comment, params)

      assert res.comment.comment == "My updated comment"
      assert res.comment.rating == 4

      assert res.order.comment_details["cli_org_rating"] == 4
    end

    test "invalid" do
      org = insert(:organization)
      cli = insert(:user_client)

      order = create_order_only(cli, org, %{status: "delivered"})
      params = %{"comment" => "My org comment", "rating" => 3, "comment_type" => "cli_org"}

      assert {:ok, res} = Order.Comment.create(order, cli, params)

      params = %{"comment" => "My updated comment", "rating" => 6}
      assert {:error, err} = Order.Comment.update(res.comment, params)

      assert err.errors[:rating]

      params = %{"comment" => "My updated comment", "rating" => 0}
      assert {:error, err} = Order.Comment.update(res.comment, params)

      assert err.errors[:rating]
    end

    test "old" do
      org = insert(:organization)
      cli = insert(:user_client)
      order = create_order_only(cli, org, %{status: "delivered"})

      t = NaiveDateTime.add(NaiveDateTime.utc_now(), -140)

      comment = insert(:comment, %{order_id: order.id, from_id: cli.id,
        to_id: org.id, rating: 4, inserted_at: t})

      params = %{"comment" => "My org comment", "rating" => 3, "comment_type" => "cli_org"}

      assert {:error, res} = Order.Comment.update(comment, params)

      assert res.errors[:inserted_at]
    end
  end
end
