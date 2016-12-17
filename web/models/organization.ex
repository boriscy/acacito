defmodule Publit.Organization do
  @moduledoc """
  The organization defines the schema in which you work
  """
  use Publit.Web, :model
  import Ecto.Query

  alias Publit.{Organization, Repo, Product}

  @derive {Poison.Encoder, only: [:id, :name, :currency, :tenant, :info, :settings]}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "organizations" do
    field :name, :string
    field :currency, :string, default: "BOB"
    field :address, :string
    field :info, :map, default: %{}
    field :settings, :map, default: %{}
    field :geom, Geo.Geometry
    field :category, :string, default: "restaurant"
    field :open, :boolean, default: false
    field :tags, Array, default: []
    field :rating, :map, default: %{}
    field :description, :string
    #field :image, :string

    has_many :products, Product

    timestamps
  end

  @currencies ~w(USD BOB)
  @categories ["restaurant", "store"]

  @doc """
  Creates organization
  """
  def create(params) do
    %Organization{}
    |> cast(params, [:name, :currency, :address, :description])
    |> validate_required([:name, :currency])
    |> validate_inclusion(:currency, @currencies)
    |> Repo.insert()
  end

  @doc """
  Updates the current organization with the new params
  """
  def update(org, params) do
    org
    |> cast(params, [:name, :address, :geom, :description])
    |> validate_required([:name, :currency, :geom])
    |> Repo.update()
  end

  @doc """
  Returns all orgs with the ids
  """
  def orgs(ids) do
    Repo.all(from o in Organization, where: o.id in ^ids)
  end

  #SELECT id, email, org->>'tenant' as tenant, org->>'active' as active, org->>'organization_id' as organization_id
  #FROM users u, jsonb_array_elements(organizations) as org
  #WHERE org->>'organization_id' = 'f40c0516-0502-4f9a-ad5b-c27b76c8fae1'
  def users(org_id) do
    sql = ~s"""
    SELECT u.id::text, u.email, u.full_name, org->>'tenant' as tenant, (org->>'active')::boolean as active, org->>'organization_id' as organization_id
    FROM users u, jsonb_array_elements(organizations) as org WHERE org->>'organization_id' = $1
    """

    {:ok, resp} = Ecto.Adapters.SQL.query(Repo, sql, [org_id])
    rows = resp.rows
    #|> Enum.map(fn(val) -> Publit.ListHelper.to_zip_to_map(resp.columns, val) end)

    {:ok, rows}
  end

  def users_map(org_id) do
    case users(org_id) do
      {:ok, usrs} ->
        Enum.into(usrs, %{}, fn(u) -> {u["id"], u} end)
    end
  end

  @doc """
  returns data to encode json for the API
  """
  def to_api(org) do
    %{
      name: org.name,
      currency: org.currency,
      address: org.address,
      pos: coords(org),
      category: org.category,
      description: org.description
    }
  end

  def coords(org) do
    case org.geom do
      nil -> %{"coordinates" => [nil, nil], "type" => "Point"}
      p -> Geo.JSON.encode(org.geom)
    end
  end

  @doc """
  """
  def set_tags(org_id) do
   {:ok, id} = Ecto.UUID.dump(org_id)
    sql = """
    with tags as (
      select unnest(p.tags) as tag from products p
      where p.organization_id = $1
    ),
    res as (
      select count(tag) as tot, tag from tags
      group by tag
    )
    select tag, tot from res
    """
    Ecto.Adapters.SQL.query(Repo, sql, [id])
  end

end
