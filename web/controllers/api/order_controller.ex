defmodule Publit.Api.OrderController do
  use Publit.Web, :controller

  # GET /api/orders
  def index(conn, _params) do
    render(conn, "index.json", orders: [fake(), fake(),
      fake(status: "process"),
      fake(status: "process", trans_start: minutes_ago(2), trans_end: nil, trans_type: "car"),
      fake(status: "transport")
    ])
  end

  # GET /api/orders/id
  def show(conn, %{"id" => id}) do
    render(conn, "show.json", order: %{id: id, total: 12.3, name: "test"})
  end

  defp fake(opts \\ []) do
    %{
      id: Ecto.UUID.generate(),
      client: "Boris Barroso",
      number: 1,
      currency: "BOB",
      status: opts[:status] || "new",
      details: [
        %{name: "Pizza", variation: "Grande", price: Decimal.new("60"), quantity: Decimal.new("1")}
      ],
      transport: %{
        start: opts[:trans_start], end: opts[:trans_end], tran_type: opts[:trans_type], user_id: opts[:trans_user_id]
      },
      inserted_at: minutes_ago(5),
      total: Decimal.new("60")
    }
  end

  defp minutes_ago(m) do
    Ecto.DateTime.from_unix!(DateTime.to_unix(DateTime.utc_now()) - m * 60, :seconds)
  end
end
