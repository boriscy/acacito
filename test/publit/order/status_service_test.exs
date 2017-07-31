defmodule Publit.Order.StatusServiceTest do
  use Publit.ModelCase
  alias Publit.{Order, Repo, UserTransport}
  import Publit.Gettext

  setup do
    %{uc: insert(:user_client), org: insert(:organization)}
  end

  def utc_diff_mins(mins \\ 5) do
    utc = :erlang.universaltime() |> :calendar.datetime_to_gregorian_seconds()
    (utc + mins * 60) |> :calendar.gregorian_seconds_to_datetime() |> Ecto.DateTime.cast!()
  end

  def ecto_to_datetime(dt) do
    Ecto.DateTime.to_erl(dt)
    |> NaiveDateTime.from_erl!()
    |> DateTime.from_naive!("Etc/UTC")
  end

  describe "next_status cange status" do
    test "change all statuses", %{uc: uc, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)

      ord = create_order(uc, org)
      u = build(:user, id: Ecto.UUID.generate())

      ptime = utc_diff_mins(5)
      {:ok, ord} = Order.StatusService.next_status(ord, u, %{"process_time" => Ecto.DateTime.to_iso8601(ptime)})

      assert ord.status == "process"
      assert ord.process_time == ecto_to_datetime(ptime)

      {:ok, ord} = Order.StatusService.next_status(ord, u)
      assert ord.status == "transport"

      {:ok, ord} = Order.StatusService.next_status(ord, u)

      assert ord.status == "transporting"
      {:ok, ord} = Order.StatusService.next_status(ord, u)

      assert ord.status == "delivered"

      log = Repo.get(Order.Log, ord.log.id)

      assert Enum.at(log.log, 0)["time"]
      assert Enum.at(log.log, 0)["user_id"] == u.id
      assert Enum.at(log.log, 0)["type"] == "log"
      assert Enum.at(log.log, 0)["msg"] == "Change status from new to process"
      assert Enum.at(log.log, 1)["time"]
      assert Enum.at(log.log, 1)["user_id"] == u.id
      assert Enum.at(log.log, 1)["msg"] == "Change status from process to transport"
      assert Enum.at(log.log, 2)["time"]
      assert Enum.at(log.log, 2)["user_id"] == u.id
      assert Enum.at(log.log, 2)["msg"] == "Change status from transport to transporting"
      assert Enum.at(log.log, 3)["time"]
      assert Enum.at(log.log, 3)["user_id"] == u.id
      assert Enum.at(log.log, 3)["msg"] == "Change status from transporting to delivered"

      data = Publit.MessageApiMock.get_data()

      Enum.each(data, fn(v) ->
        assert ["devtokencli1234"] == v[:tokens]
      end)
    end

    test "Error process_time", %{uc: uc, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)

      ord = create_order(uc, org)
      u = build(:user, id: Ecto.UUID.generate())

      ptime = utc_diff_mins(0)

      assert :error == Order.StatusService.next_status(ord, u, %{"process_time" => Ecto.DateTime.to_iso8601(ptime)})
    end

    test "messages", %{uc: uc, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)

      ord = create_order(uc, org)
      u = build(:user, id: Ecto.UUID.generate())

      ptime = utc_diff_mins(5)

      {:ok, ord} = Order.StatusService.next_status(ord, u, %{"process_time" => Ecto.DateTime.to_iso8601(ptime) })
      assert ord.process_time == ecto_to_datetime(ptime)

      Process.sleep(50)

      resp = Agent.get(:api_mock, fn(v) -> v end) |> List.first()

      assert resp[:tokens] == ["devtokencli1234"]
      assert resp[:msg][:message] == gettext("Yor order will be processed")
      assert resp[:msg][:data][:order][:status] == "process"
    end

    test "transport to transporting", %{uc: uc, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)

      ord = create_order_only(uc, org, %{status: "transport"})
      {ord, ut} = update_order_and_create_user_transport(ord)
      user = build(:user, id: Ecto.UUID.generate())

      ordt = ut.orders |> List.first()
      assert ordt["status"] == "transport"

      {:ok, ord} = Order.StatusService.next_status(ord, user)

      assert ord.transport.picked_at
      assert ord.status == "transporting"

      ut = Repo.get(UserTransport, ut.id)

      ordt = ut.orders |> List.first()

      assert ordt["id"] == ord.id
      assert ordt["status"] == "transporting"

      data = Publit.MessageApiMock.get_data()
      dt = data |> List.first()

      assert dt[:msg][:message] == gettext("Your order is on the way")
      assert dt[:msg][:data][:order][:id] == ord.id

      assert dt[:tokens] == [ut.extra_data["device_token"]]

      dc = data |> List.last()

      assert dc[:msg][:message] == gettext("Your order is on the way")
      assert dc[:msg][:data][:order][:id] == ord.id

      assert dc[:tokens] == [uc.extra_data["device_token"]]
    end

    test "transporting to delivered", %{uc: uc, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)
      ord = create_order_only(uc, org, %{status: "transporting"})
      {ord, ut} = update_order_and_create_user_transport(ord)

      assert Enum.count(ut.orders) == 1

      {:ok, ord} = Order.StatusService.next_status(ord, ut)

      assert ord.transport.delivered_at
      assert ord.status == "delivered"

      ut = Repo.get(UserTransport, ut.id)

      assert ut.orders |> Enum.count() == 0
      assert ut.extra_data["trans_status"] == "listen"

      data = Publit.MessageApiMock.get_data()

      assert Enum.count(data) == 1
      data = data |> List.first()

      assert data[:tokens] == [uc.extra_data["device_token"]]
      assert data[:msg][:data][:status] == "order:updated"
      assert data[:msg][:title] == gettext("Order delivered")
      assert data[:msg][:message] == gettext("Your order has been delivered")
    end

    test "process to ready", %{uc: uc, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)

      ord = create_order_only(uc, org, %{status: "process", transport: %Order.Transport{calculated_price: Decimal.new("5"), transport_type: "pickandpay"} })
      user = build(:user, id: Ecto.UUID.generate())

      assert ord.transport.transport_type == "pickandpay"

      {:ok, ord} = Order.StatusService.next_status(ord, user)

      assert ord.status == "ready"

      Process.sleep(10)
      data = Publit.MessageApiMock.get_data()
      dt = data |> List.first()

      assert dt[:msg][:message] == gettext("Your order is ready")
      assert dt[:msg][:data][:order][:id] == ord.id
    end

    test "ready to delivered", %{uc: uc, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)

      ord = create_order_only(uc, org, %{status: "ready", transport: %Order.Transport{calculated_price: Decimal.new("5"), transport_type: "pickandpay"} })
      user = build(:user, id: Ecto.UUID.generate())

      assert ord.transport.transport_type == "pickandpay"

      {:ok, ord} = Order.StatusService.next_status(ord, user)

      assert ord.status == "delivered"

      Process.sleep(10) # Required, sometimes agent is not updated at the same time
      data = Publit.MessageApiMock.get_data()
      dt = data |> List.first()

      assert dt[:msg][:message] == gettext("Your order has been delivered")
      assert dt[:msg][:data][:order][:id] == ord.id
    end

  end

  describe "previous" do
    test "process -> new", %{uc: uc, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)
      ord = create_order(uc, org)
      u = build(:user, id: Ecto.UUID.generate())

      ptime = utc_diff_mins(5)
      {:ok, ord} = Order.StatusService.next_status(ord, u, %{"process_time" => Ecto.DateTime.to_iso8601(ptime)})
      assert ord.status == "process"
      assert ord.process_time == ecto_to_datetime(ptime)

      {:ok, ord} = Order.StatusService.previous_status(ord, u)
      assert ord.status == "new"

      log = Repo.get_by(Order.Log, order_id: ord.id, log_type: "Order")

      assert Enum.at(log.log, 0)["time"]
      assert Enum.at(log.log, 0)["user_id"] == u.id
      assert Enum.at(log.log, 0)["type"] == "log"
      assert Enum.at(log.log, 0)["msg"] == "Change status from new to process"
      assert Enum.at(log.log, 1)["time"]
      assert Enum.at(log.log, 1)["user_id"] == u.id
      assert Enum.at(log.log, 1)["msg"] == "Change status from process to new"

      msg = Agent.get(:api_mock, fn(v) -> v end) |> List.last()
      assert msg[:msg][:message] == gettext("Don't worry we are working on your order, there was a small error updating your order status")
      assert msg[:msg][:data][:order][:status] == "new"
    end

    test "transport -> process", %{uc: uc, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)

      ot = %Order.Transport{id: "4b93eb0a-9bc9-4946-b6c3-20004ac19837", plate: "AA", vehicle: "bike", picked_at: nil, delivered_at: nil, responded_at: "2017-07-31T12:00:11.641217Z",
       mobile_number: "59173737788", transport_type: "delivery", transporter_id: "4b93eb0a-9bc9-4946-b6c3-20004ac19838", calculated_price: Decimal.new("10"),
       transporter_name: "Fercho", picked_arrived_at: "12:33", final_price: Decimal.new("10"), delivered_at: "12:22"
      }
      ord = create_order_only(uc, org, %{status: "transport", transport: ot})

      assert ord.status == "transport"

      assert %Order.Transport{vehicle: "bike", plate: "AA", responded_at: "2017-07-31T12:00:11.641217Z"} = ord.transport

      u = build(:user, id: Ecto.UUID.generate())
      {:ok, ord} = Order.StatusService.previous_status(ord, u)

      assert ord.status == "process"
      assert ord.transport.responded_at == nil
      msg = Agent.get(:api_mock, fn(v) -> v end) |> List.last()
      assert msg[:msg][:data][:order][:status] == "process"
      ot = msg[:msg][:data][:order][:transport]
      assert ot.responded_at == nil
    end

    test "ready -> process", %{uc: uc, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)

      ord = create_order_only(uc, org, %{status: "ready"})

      assert ord.status == "ready"

      u = build(:user, id: Ecto.UUID.generate())
      {:ok, ord} = Order.StatusService.previous_status(ord, u)

      assert ord.status == "process"
    end

    test "transporting -> transport", %{uc: uc, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)

      ord = create_order_only(uc, org, %{status: "transporting"})

      assert ord.status == "transporting"

      u = build(:user, id: Ecto.UUID.generate())
      {:ok, ord} = Order.StatusService.previous_status(ord, u)

      assert ord.status == "transport"
    end
  end

end
