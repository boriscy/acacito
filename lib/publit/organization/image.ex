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

  def changeset(org_img, params) do
    cast(org_img, params, [:name, :description])
    |> validate_required([:image])
    |> cast_attachments(params, [:image])
  end

end
