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
      assert Map.keys(ord) == [:chat, :client_address, :client_name, :client_number,
       :client_pos, :comment_details, :currency, :details, :id, :inserted_at,
       :log, :null_reason, :num, :order_calls, :organization, :organization_address,
       :organization_id, :organization_name, :organization_number, :organization_pos, :other_details,
       :process_time, :status, :total, :transport, :transport_time, :updated_at,
       :user_client, :user_client_id, :user_transport, :user_transport_id]
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
