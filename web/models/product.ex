defmodule Publit.Product do
  use Publit.Web, :model
  use Arc.Ecto.Schema
  import Ecto.Query
  alias Publit.{Product, Repo, ProductVariation}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "products" do
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :publish, :boolean, default: false
    field :currency, :string, default: "BOB"
    field :tags, Array
    field :unit, :string
    field :image, Publit.ProductImage.Type
    field :extra_info, :map, default: %{}
    field :pos, :integer, default: 1
    field :has_inventory, :boolean, default: true
    field :moderated, :boolean, default: false, null: false

    belongs_to :organization, Publit.Organization, type: :binary_id

    embeds_many :variations, ProductVariation, on_replace: :delete

    timestamps()
  end

  def cast() do

  end

  @doc """
  Builds and empte product
  """
  def new() do
    Ecto.Changeset.change(%Product{variations: [%ProductVariation{}, %ProductVariation{}]})
  end

  @doc """
  Creates a new product and checks validations
  """
  @spec create(map) :: any
  def create(params) do
    %Product{}
    |> cast(params, [:name, :description, :organization_id, :tags])
    |> cast_attachments(params, [:image])
    |> validate_required([:name, :organization_id])
    |> cast_embed(:variations)
    |> Repo.insert()
  end

  @doc """
  Updates a product attributes except organization_id
  """
  def update(product, params) do
    product
    |> cast(params, [:name, :description, :publish, :tags])
    |> set_image(params)
    |> cast_embed(:variations)
    |> validate_required([:name])
    |> Repo.update()
  end

  def delete(product) do
    if product.image do
      try do
        Publit.ProductImage.delete_all(product)
      rescue
        _ ->
      end
    end

    Repo.delete(product)
  end

  defp set_image(cs, params) do
    case params["image"] do
      %Plug.Upload{path: _p} ->
        cast_attachments(cs, params, [:image])
      _ -> cs
    end
  end

  @doc """
  Returns products for a certain organization
  """
  def all(org_id) do
    Repo.all(from p in Product,
     where: p.organization_id == ^org_id,
     order_by: [asc: p.name])
  end

  def published(org_id) do
    Repo.all(from p in Product,
     where: p.organization_id == ^org_id and p.publish == true,
     order_by: [asc: p.name])
  end

end
