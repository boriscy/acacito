defmodule Publit.Order.Log do
  use PublitWeb, :model
  import Ecto.Query
  alias Publit.{Order, Repo}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "order_logs" do

    field :log_type, :string, default: "Order"
    field :log, {:array, :map}, default: []

    belongs_to :order, Order, type: :binary_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def add(ol = %Order.Log{}, params \\ %{}) do
    msg = params
    |> Map.put("time", to_string(DateTime.utc_now()))
    |> Map.put("type", params["type"] || "log")

    change(ol)
    |> put_change(:log, ol.log ++ [msg])
  end

  def add(order_id, params) do
    msg = params
    |> Map.put("time", to_string(DateTime.utc_now()))
    |> Map.put("type", params["type"] || "log")

    {:ok, uid} = Ecto.UUID.dump(order_id)

    sql = "UPDATE order_logs SET log = array_append(log, $1::jsonb) where order_id = $2 AND log_type='Order'"
    Ecto.Adapters.SQL.query(Repo, sql, [msg, uid])
  end

end
