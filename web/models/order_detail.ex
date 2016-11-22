defmodule Publit.OrderDetail do
  use Publit.Web, :model

  embedded_schema do
    field :name, :string
    field :variation, :string
    field :product_id, :binary
    field :variation_id, :binary
    field :quantity, :decimal, default: 1
    field :price, :decimal, default: nil
  end

  def changeset(cs, params) do
    cs
    |> cast(params, [:product_id, :variation_id, :quantity])
    |> validate_required([:product_id, :variation_id, :quantity])
    |> validate_number(:quantity, greater_than: Decimal.new("0"))
  end
end