defmodule Publit.Order.NullTest do
  use Publit.ModelCase
  import Publit.Support.Session, only: [create_user_org: 1]

  alias Publit.{Order, ProductVariation, Repo}

  describe "null" do
    test "new" do
      Agent.start_link(fn() -> []  end, name: :api_mock )
      org = insert(:organization)
      uc = insert(:user_client)
      user = insert(:user)

      order = create_order_only(uc, org)
      insert(:order_log, %{order_id: order.id, log: []})

      assert order.status == "new"

      {:ok, ord} = Order.Null.null(order, user, %{"null_reason" => "No more items"})

      assert ord.status == "nulled"
      assert ord.null_reason == "No more items"

      ord = Repo.preload(ord, :log)

      log = ord.log

      msg = log.log |> List.first

      assert msg["type"] == "status:nulled"
      assert msg["user_id"] == user.id

      msg = Agent.get(:api_mock, fn(v) -> v end) |> List.first

      ord = msg[:msg][:data][:order]
      assert Map.keys(ord) == [:chat, :cli, :client_pos, :comment_details, :currency, :details, :id,
        :inserted_at, :log, :null_reason, :num, :order_calls, :org, :organization, :organization_id,
        :organization_pos, :other_details, :prev_status, :process_time, :status, :total, :trans, :transport_time,
        :updated_at, :user_client, :user_client_id, :user_transport, :user_transport_id]
    end

    test "process" do
      Agent.start_link(fn() -> []  end, name: :api_mock )
      org = insert(:organization)
      uc = insert(:user_client)
      user = insert(:user)

      order = create_order_only(uc, org, %{status: "process"})
      insert(:order_log, %{order_id: order.id, log: []})

      assert order.status == "process"

      {:ok, ord} = Order.Null.null(order, user, %{"null_reason" => "No more items"})

      assert ord.status == "nulled"
      assert ord.null_reason == "No more items"
    end

    test "ready" do
      Agent.start_link(fn() -> []  end, name: :api_mock )
      org = insert(:organization)
      uc = insert(:user_client)
      user = insert(:user)

      order = create_order_only(uc, org, %{status: "ready"})
      insert(:order_log, %{order_id: order.id, log: []})

      assert order.status == "ready"

      {:ok, ord} = Order.Null.null(order, user, %{"null_reason" => "No more items"})

      assert ord.status == "nulled"
      assert ord.null_reason == "No more items"
    end

    test "transport" do
      Agent.start_link(fn() -> []  end, name: :api_mock )
      org = insert(:organization)
      uc = insert(:user_client)
      user = insert(:user)

      order = create_order_only(uc, org, %{status: "transport"})
      insert(:order_log, %{order_id: order.id, log: []})

      assert order.status == "transport"

      {:ok, ord} = Order.Null.null(order, user, %{"null_reason" => "No more items"})

      assert ord.status == "nulled"
      assert ord.null_reason == "No more items"
    end

    test "transporting" do
      Agent.start_link(fn() -> []  end, name: :api_mock )
      org = insert(:organization)
      uc = insert(:user_client)
      user = insert(:user)

      order = create_order_only(uc, org, %{status: "transporting"})
      insert(:order_log, %{order_id: order.id, log: []})

      assert order.status == "transporting"

      {:ok, ord} = Order.Null.null(order, user, %{"null_reason" => "No more items"})

      assert ord.status == "nulled"
      assert ord.null_reason == "No more items"
    end

    test "invalid" do
      org = insert(:organization)
      uc = insert(:user_client)
      user = build(:user)

      order = create_order_only(uc, org, %{status: "delivered"})

      assert order.status == "delivered"

      assert catch_error(Order.Null.null(order, user, %{"null_reason" => "No more items"}) )
    end

    test "invalid reason" do
      org = insert(:organization)
      uc = insert(:user_client)
      user = build(:user)
      order = create_order_only(uc, org)

      assert {:error, :order, cs} = Order.Null.null(order, user, %{"null_reason" => "No"})
      assert cs.errors[:null_reason]
    end

  end
end
