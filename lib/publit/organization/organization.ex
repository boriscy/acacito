defmodule Publit.Organization do
  @moduledoc """
  The organization defines the schema in which you work
  """
  use PublitWeb, :model
  import Ecto.Query

  alias Publit.{Organization, Repo, Product}

  @number_reg ~r|^591[6,7]\d{7}$|

  @derive {Poison.Encoder, only: [:id, :name, :currency, :tenant, :info, :settings]}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "organizations" do
    field :name, :string
    field :currency, :string, default: "BOB"
    field :address, :string
    field :info, :map, default: %{}
    field :settings, :map, default: %{}
    field :pos, Geo.Geometry
    field :category, :string, default: "restaurant"
    field :open, :boolean, default: false
    field :tags, Publit.Array, default: []
    field :rating, :decimal
    field :rating_count, :integer
    field :description, :string
    field :mobile_number, :string

    has_many :products, Product

    embeds_many :images, Organization.Image, on_replace: :delete

    timestamps()
  end

  @currencies ~w(USD BOB)
  @categories ["restaurant", "store"]

  def changeset(mod, params) do
    mod
  end


  @doc """
  Creates organization
  """
  def create(params) do
    %Organization{}
    |> cast(params, [:name, :currency, :address, :description, :mobile_number])
    |> validate_required([:name, :currency, :mobile_number])
    |> validate_inclusion(:currency, @currencies)
    |> validate_format(:mobile_number, @number_reg)
    |> Repo.insert()
  end

  def update_images(org, params) do
    images = Publit.Util.map_to_list(params["images"], :atom)
    |> Enum.map( fn(img) -> Organization.Image.set_image(org, img) end)

    change(org)
    |> put_embed(:images, images)
    |> Repo.update()
  end

  @doc """
  Updates the current organization with the new params
  """
  def update(org, params) do
    org
    |> cast(params, [:name, :address, :pos, :description, :mobile_number])
    |> validate_required([:name, :currency, :pos, :mobile_number])
    |> validate_format(:mobile_number, @number_reg)
    |> Repo.update()
  end

  @doc """
  Opens or closes an organization
  """
  def open_close(org, user_id) do
    cs = change(org)
    |> put_change(:open, !org.open)

    cs = if org.open do
      cs |> put_change(:info, Map.merge(org.info, %{"last_closed_by" => user_id}))
    else
      cs |> put_change(:info, Map.merge(org.info, %{"last_opened_by" => user_id}))
    end

    Repo.update(cs)
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

  def coords(org) do
    case org.pos do
      nil -> %{"coordinates" => [nil, nil], "type" => "Point"}
      p -> Geo.JSON.encode(org.pos)
    end
  end

  @doc """
  """
  def set_tags(org_id) do
   {:ok, id} = Ecto.UUID.dump(org_id)
    sql = """
    with tags as (
      select unnest(p.tags) as tag, p.id from products p
      where p.published = true and p.organization_id = $1
      union
      select 'producto', '377ad713-16d2-45c2-8d7c-79c074408140'
    ),
    res as (
      select count(tag) as count, tag from tags
      group by tag
      order by count desc
      limit 10
    )
    update organizations
    set tags = (select json_agg(row_to_json(res)) from res)
    where id = $1
    """

    Ecto.Adapters.SQL.query(Repo, sql, [id])
  end

end
