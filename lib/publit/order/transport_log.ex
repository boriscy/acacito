defmodule Publit.Order.TransportLog do
  use PublitWeb, :model
  alias Publit.{OrderLog}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "order_logs" do

    field :log_type, :string, default: "Transport"
    field :log, {:array, :map}, default: []

    belongs_to :order, Order, type: :binary_id
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:log])
  end
end
