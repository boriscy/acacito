defmodule Publit.Api.OrderController do
  use Publit.Web, :controller

  # GET /api/orders
  def index(conn, _params) do
    {:ok, a} = Agent.start(fn() -> 1 end)
    render(conn, "index.json", orders: [fake(a), fake(a),
      fake(a, status: "process"),
      fake(a, status: "process", trans_start: minutes_ago(2), trans_end: nil, trans_type: "car"),
      fake(a, status: "transport")
    ])
  end

  # GET /api/orders/id
  def show(conn, %{"id" => id}) do
    render(conn, "show.json", order: %{id: id, total: 12.3, name: "test"})
  end

  defp fake(a, opts \\ []) do
    num = Agent.get(a, &(&1) )
    Agent.update(a, &(&1 + 1))

    %{
      id: "#{num}-aa",
      client: "Boris Barroso",
      number: num,
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
