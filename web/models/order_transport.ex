defmodule Publit.OrderTransport do
  use Publit.Web, :model

  alias Publit.{OrderTransport}

  embedded_schema do
    field :transporter_id, :binary
    field :transporter_name, :string
    field :calculated_price, :decimal
    field :final_price, :decimal
    field :contact_location, :map
    field :start_location, :map
    field :end_location, :map
    field :log, {:array, :map}, default: []
  end

  @doc """
  cangeset for creation of order
  """
  def changeset(pv, params) do
    cast(pv, params, [:calculated_price, :start_location, :end_location])
    |> validate_required([:calculated_price, :start_location, :end_location])
    |> validate_number(:calculated_price, greater_than_or_equal_to: 0)
  end

end
