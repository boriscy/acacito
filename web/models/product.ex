defmodule Publit.Product do
  use Publit.Web, :model
  use Arc.Ecto.Schema
  import Ecto.Query
  alias Publit.{Product, Repo, ProductVariation, Organization}
  alias Ecto.Multi

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "products" do
    field :name, :string
    field :description, :string
    field :publish, :boolean, default: false
    field :currency, :string, default: "BOB"
    field :tags, Publit.Array, default: []
    field :unit, :string
    field :image, Publit.ProductImage.Type
    field :extra_info, :map, default: %{}
    field :pos, :integer, default: 1
    field :has_inventory, :boolean, default: true
    field :moderated, :boolean, default: false, null: false
    field :category, :string

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
  @spec create(map) :: any
  def create(params) do
    %Product{}
    |> cast(params, [:name, :description, :organization_id, :tags, :category])
    |> put_change(:id, Ecto.UUID.generate())
    |> cast_attachments(params, [:image])
    |> validate_required([:name, :organization_id])
    |> cast_embed(:variations)
    |> Repo.insert()
  end

  @doc """
  Updates a product attributes except organization_id
  """
  def update(product, params) do
    cs = product
    |> cast(params, [:name, :description, :publish, :tags, :category])
    |> set_image(params)
    |> cast_embed(:variations)
    |> validate_required([:name])

    case cs.valid? do
      true ->
        multi = Multi.new()
        |> Multi.update(:product, cs)
        |> Multi.run(:tags, fn(_) -> Organization.set_tags(cs.data.organization_id) end)

        case Repo.transaction(multi) do
          {:ok, res} -> {:ok, res.product}
          {:error, _res} -> {:error, cs}
        end
      false -> {:error, cs}
    end
  end

  def delete(product) do
    if product.image do
      try do
        path = product.image.file_name
        Task.async(fn -> Publit.ProductImage.delete({path, product}) end)
      rescue
        _ -> nil
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

  # Convert to markdown a field
  defp markdown(cs, field) do
    if cs.changes[field] do
      data = Map.merge(cs.data.extra_info, cs.changes[:extra_info] || %{})
      {:safe, esc_text} = Phoenix.HTML.html_escape(cs.changes[field])
      data = Map.put(data, "#{field}HTML", Earmark.to_html(esc_text))

      put_change(cs, :extra_info, data)
    else
      cs
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

  @doc """
  Returns one product that is published and belongs to an organization
  """
  def get(org_id, prod_id) do
    Repo.one(from p in Product,
     where: p.organization_id == ^org_id and p.publish == true and p.id == ^prod_id)
  end

  def all_tags(org_id) do
    Repo.all(from p in Product, select: fragment("DISTINCT(UNNEST(tags)) AS tags"),
    where: p.organization_id == ^org_id ,order_by: [asc: fragment("tags")]  )
  end

end
