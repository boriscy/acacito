defmodule Publit.Organization.Image do
  use Publit.Web, :model
  use Arc.Ecto.Schema

  embedded_schema do
    field :image, Publit.Organization.ImageUploader.Type
    field :name, :string
    field :description, :string

    timestamps()
  end

  @doc """
  Adds product variations to a product changeset
  """
  #def add(product_cs, params \\ []) do
  #  pc = product_cs
  #  |> put_embed(:variations, set_variations(params))
  #  pc
  #end

  def changeset(org, params) do
    cast(org, params, [:name, :description])
    |> validate_required([:price])
    |> cast_attachments(params, [:image])
  end

end
