defmodule Publit.ProductVariation do
  use Publit.Web, :model

  alias Publit.{ProductVariation}

  embedded_schema do
    field :name, :string
    field :price, :decimal, default: 0.0
    field :description, :string
  end

  @doc """
  Adds product variations to a product changeset
  """
  def add(product_cs, params \\ []) do
    product_cs
    |> put_embed(:variations, set_variations(params))
  end

  def changeset(pv, params) do
    cast(pv, params, [:name, :price, :description, :id])
    |> validate_required([:name, :price])
    |> validate_number(:price, greater_than_or_equal_to: 0)
  end

  defp set_variations(params) do
    cond do
      is_list(params) && Enum.count(params) >  0 ->
        Enum.map(params, fn(p) -> changeset(%ProductVariation{}, p) end)
      true ->
        [changeset(%ProductVariation{}, %{})]
    end
  end
end
