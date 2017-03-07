defmodule Publit.OrderStatusServiceTest do
  use Publit.ModelCase
  alias Publit.{OrderStatusService, Repo, UserTransport}

  setup do
    %{uc: insert(:user_client), org: insert(:organization)}
  end

  describe "Change status" do
    test "change to process", %{uc: uc, org: org} do
      ord = create_order(uc, org)
      assert Enum.count(ord.log) == 1

      {:ok, ord} = OrderStatusService.next_status(ord, Ecto.UUID.generate() )
      assert Enum.count(ord.log) == 2
      assert ord.status == "process"

      {ord, _ut} = update_order_and_create_user_transport(ord)

      {:ok, ord} = OrderStatusService.next_status(ord, Ecto.UUID.generate() )
      assert Enum.count(ord.log) == 3
      assert ord.status == "transport"

      {:ok, ord} = OrderStatusService.next_status(ord, Ecto.UUID.generate() )
      assert Enum.count(ord.log) == 4

      assert ord.status == "transporting"


      {:ok, ord} = OrderStatusService.next_status(ord, Ecto.UUID.generate() )
      assert Enum.count(ord.log) == 5

      assert ord.status == "delivered"
    end

    test "transport to transporting", %{uc: uc, org: org} do
      ord = create_order_only(uc, org, %{status: "transport"})
      {ord, ut} = update_order_and_create_user_transport(ord)

      ordt = ut.orders |> List.first()
      assert ordt["status"] == "transport"

      {:ok, ord} = OrderStatusService.next_status(ord, Ecto.UUID.generate() )

      assert ord.transport.picked_at
      assert ord.status == "transporting"

      ut = Repo.get(UserTransport, ut.id)

      ordt = ut.orders |> List.first()

      assert ordt["order_id"] == ord.id
      assert ordt["status"] == "transporting"
      assert ordt["picked_at"]
    end

    test "transporting to delivered", %{uc: uc, org: org} do
      ord = create_order_only(uc, org, %{status: "transporting"})
      {ord, ut} = update_order_and_create_user_transport(ord)

      assert Enum.count(ut.orders) == 1

      {:ok, ord} = OrderStatusService.next_status(ord, Ecto.UUID.generate() )

      assert ord.transport.delivered_at
      assert ord.status == "delivered"

      ut = Repo.get(UserTransport, ut.id)

      assert ut.orders |> Enum.count() == 0
    end

    test "previous", %{uc: uc, org: org} do
      ord = create_order(uc, org)
      assert Enum.count(ord.log) == 1

      {:ok, ord} = OrderStatusService.next_status(ord, Ecto.UUID.generate() )
      assert Enum.count(ord.log) == 2
      assert ord.status == "process"
      log = ord.log |> List.last
      assert log[:type] == "update_next"

      {:ok, ord} = OrderStatusService.previous_status(ord, Ecto.UUID.generate() )
      assert Enum.count(ord.log) == 3
      assert ord.status == "new"
      log = ord.log |> List.last
      assert log[:type] == "update_back"
    end

  end
end
