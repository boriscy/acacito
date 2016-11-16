defmodule Publit.Product do
  use Publit.Web, :model
  use Arc.Ecto.Schema
  import Ecto.Query
  alias Publit.{Product, Repo, ProductVariation}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "products" do
    field :name, :string
    field :description, :string
    field :price, :decimal, default: 0.0
    field :publish, :boolean, default: false
    field :currency, :string, default: "BOB"
    #field :tags, :list
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

  @doc """
  Builds and empte product
  """
  def new() do
    Ecto.Changeset.change(%Product{variations: [%ProductVariation{}, %ProductVariation{}]})
  end

  @doc """
  Creates a new product and checks validations
  """
  def create(params) do
    %Product{}
    |> cast(params, [:name, :description, :price, :organization_id])
    |> cast_attachments(params, [:image])
    |> validate_required([:name, :organization_id])
    |> ProductVariation.add(params["variations"])
    |> Repo.insert()
  end

  def update(product, params) do
    product
    |> cast(params, [:name, :description])
    |> cast_attachments(params, [:image])
    |> validate_required([:name])
    |> ProductVariation.add(params["variations"])
    |> Repo.update()
  end

  @doc """
  Returns products for a certain organization
  """
  def all(org_id) do
    Repo.all(from p in Product,
     where: p.organization_id == ^org_id,
     order_by: [asc: p.name])
  end
end
