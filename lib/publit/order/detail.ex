defmodule Publit.Order.Detail do
  use Publit.Web, :model

  @primary_key false
  embedded_schema do
    field :name, :string
    field :variation, :string
    field :product_id, :binary
    field :variation_id, :binary
    field :quantity, :decimal, default: 1
    field :price, :decimal, default: nil
    field :image_thumb, :string
  end

  def changeset(cs, params) do
    cs
    |> cast(params, [:product_id, :variation_id, :quantity, :image_thumb])
    |> validate_required([:product_id, :variation_id, :quantity])
    |> validate_number(:quantity, greater_than: Decimal.new("0"))
  end
end
