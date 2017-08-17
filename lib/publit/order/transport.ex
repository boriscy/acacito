defmodule Publit.Order.Transport do
  use Publit.Web, :model
  alias Publit.{Order, Repo}

  @primary_key false
  embedded_schema do
    field :transporter_id, :binary
    field :name, :string
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
    field :ctype, :string
  end

  @ctypes ["delivery", "pickup"]

  @doc """
  cangeset for creation of order
  """
  def changeset_create(cs) do
    params = cs.params["trans"] || %{}

    cast(%Order.Transport{}, params, [:calculated_price, :ctype])
    |> validate_required([:calculated_price, :ctype])
    |> validate_inclusion(:ctype, @ctypes)
    |> validate_number(:calculated_price, greater_than_or_equal_to: 0)
  end

  def changeset_update(ot, %Publit.UserTransport{} = ut , params) do
    Map.merge(ot, %{transporter_id: ut.id, name: ut.full_name,
               vehicle: ut.vehicle, plate: ut.plate, mobile_number: ut.mobile_number})
    |> cast(params, [:final_price])
    |> validate_number(:final_price, greater_than_or_equal_to: 0)
    |> put_change(:responded_at, DateTime.utc_now())
  end

  def changeset_delivery(ot, params) do
    ot
    |> put_change(params, [:picked_arrived_at, :delivered_arrived_at])
  end

  def add_log(o_trans, pos) do
    o_trans.log ++ [%{pos: pos, time: DateTime.utc_now()}]
  end

end
