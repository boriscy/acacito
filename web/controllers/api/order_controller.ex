defmodule Publit.Api.OrderController do
  use Publit.Web, :controller

  # GET /api/orders
  def index(conn, _params) do
    render(conn, "index.json", orders: [fake()])
  end

  # GET /api/orders/id
  def show(conn, %{"id" => id}) do
    render(conn, "show.json", order: %{id: id, total: 12.3, name: "test"})
  end

  defp fake do
    %{
      client: "Boris Barroso",
      number: 1,
      currency: "BOB",
      details: [
        %{name: "Pizza", variation: "Grande", price: Decimal.new("60"), quantity: Decimal.new("1")}
      ],
      inserted_at: minutes_ago(3),
      total: Decimal.new("60")
    }
  end

  defp minutes_ago(m) do
    Ecto.DateTime.from_unix!(DateTime.to_unix(DateTime.utc_now()) - m * 60, :seconds)
  end
end
