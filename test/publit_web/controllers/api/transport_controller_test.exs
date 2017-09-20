defmodule Publit.Api.TransportControllerTest do
  use PublitWeb.ConnCase
  alias Publit.{Order, Repo, UserTransport}

  setup do
    {user, org} = create_user_org()
    conn = build_conn()
    |> assign(:current_user, user)
    |> assign(:current_organization, org)

    %{conn: conn, user: user, org: org}
  end

  defp order do
   %Order{id: Ecto.UUID.generate(), organization_pos: %Geo.Point{coordinates: { -63.8748, -18.1778 }, srid: nil},
          client_pos: %Geo.Point{coordinates: { -63.8748, -18.1778 }, srid: nil} }
  end

  defp user_transports do
    [
      %UserTransport{mobile_number: "11223344", status: "listen", pos: %Geo.Point{coordinates: {-63.876047,-18.1787804}, srid: nil},
      extra_data: %{device_token: "11223344"}},
      %UserTransport{mobile_number: "22334455", status: "listen", pos: %Geo.Point{coordinates: {-63.8732718,-18.1767489}, srid: nil},
      extra_data: %{device_token: "22334455"}}
    ]
  end

  describe "POST /api/transport" do
    test "OK", %{conn: conn, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)

      uc = insert(:user_client)
      {:ok, ord} = Repo.insert(Map.merge(order(), %{organization_id: org.id, user_client_id: uc.id}))
      user_transports() |> Enum.map(&Repo.insert/1)

      conn = post(conn, "/api/transport", %{order_id: ord.id})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert json["order_call"]["id"]
      assert json["order_call"]["status"] == "new"
    end

    test "Not found", %{conn: conn} do
      Agent.start_link(fn -> [] end, name: :api_mock)
      conn = post(conn, "/api/transport", %{order_id: Ecto.UUID.generate() })

      assert conn.status == 404
      json = Poison.decode!(conn.resp_body)
      assert gettext("Order not found") == json["message"]
    end

    test "empty", %{conn: conn, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)
      uc = insert(:user_client)
      {:ok, ord} = Repo.insert(Map.merge(order(), %{organization_id: org.id, user_client_id: uc.id}))

      conn = post(conn, "/api/transport", %{order_id: ord.id})
      assert conn.status == Plug.Conn.Status.code(:failed_dependency)
    end
  end

  describe "DELETE /api/transport/:id" do
    test "OK", %{conn: conn, org: org} do
      Agent.start_link(fn -> [] end, name: :api_mock)
      uc = insert(:user_client)
      order = create_order_only(uc, org)
      assert {:ok, _} = Repo.insert(%Order.Call{order_id: order.id, status: "new"})

      assert Repo.all(Order.Call) |> Enum.count() == 1
      conn = delete(conn, "/api/transport/#{order.id}")

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert json["order"]["id"] == order.id
      assert Repo.all(Order.Call) |> Enum.count() == 0
    end
  end

end
