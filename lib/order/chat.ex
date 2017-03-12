defmodule Publit.Order.Chat do
  use Publit.Web, :model
  alias Publit.{OrderLog}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "order_logs" do

    field :log_type, :string, default: "Chat"
    field :log, {:array, :map}, default: []

    belongs_to :order, Order, type: :binary_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def add_chat() do
  end
end

