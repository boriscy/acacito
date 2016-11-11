defmodule Publit.Product do
  use Publit.Web, :model
  import Ecto.Query
  alias Publit.{Product, Repo}


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
    timestamps()
  end


  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :price, :publish])
    |> validate_required([:name, :price, :publish])
  end

  def new() do
    Ecto.Changeset.change(%Product{})
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
