defmodule Publit.Order.Transport do
  use Publit.Web, :model

  embedded_schema do
    field :transporter_id, :binary
    field :transporter_name, :string
    field :mobile_number, :string
    field :vehicle, :string
    field :plate, :string
    field :calculated_price, :decimal
    field :final_price, :decimal
    field :responded_at, :string
    field :picked_arrived_at, :string
    field :picked_at, :string
    field :delivered_arrived_at, :string
    field :delivered_at, :string
    field :transport_type, :string
  end

  @transport_types ["deliver", "pickandpay"]

  @doc """
  cangeset for creation of order
  """
  def changeset(pv, params) do
    cast(pv, params, [:calculated_price, :transport_type])
    |> validate_required([:calculated_price, :transport_type])
    |> validate_inclusion(:transport_type, @transport_types)
    |> validate_number(:calculated_price, greater_than_or_equal_to: 0)
  end

  def changeset_update(ot, params) do
    ot
    |> cast(params, [:transporter_id, :transporter_name, :mobile_number, :final_price, :plate, :vehicle])
    |> validate_required([:transporter_id, :transporter_name, :final_price, :vehicle])
    |> validate_number(:final_price, greater_than_or_equal_to: 0)
    |> put_change(:responded_at, DateTime.utc_now())
  end

  def changeset_delivery(ot, params) do
    ot
    |> cast(params, [:picked_arrived_at, :delivered_arrived_at])
  end

  def add_log(o_trans, pos) do
    o_trans.log ++ [%{pos: pos, time: DateTime.utc_now()}]
  end

end
