defmodule Publit.Organization do
  @moduledoc """
  The organization defines the schema in which you work
  """
  use Publit.Web, :model
  import Ecto.Query

  alias Publit.{Organization, Repo, OrganizationSettings}

  @derive {Poison.Encoder, only: [:id, :name, :currency, :tenant, :info, :settings]}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "organizations" do
    field :name, :string
    field :currency, :string
    field :info, :map, default: %{}
    field :geom, Geo.Geometry

    timestamps
  end

  @required_fields ~w(name currency tenant)
  @optional_fields ~w(info settings)

  @currencies ~w(USD BOB)


  def create(params) do
    %Organization{}
    |> cast(params, [:name, :currency, :address])
  end

  def changeset(model, params \\ %{}) do
    cast(model, params, [:name, :currency, :tenant])
    |> validate_required([:name, :currency, :tenant])
    |> validate_inclusion(:currency, @currencies)
    |> cast_embed(:settings)
    #|> put_embed(:settings, OrganizationSettings.changeset(%OrganizationSettings{}, params[:settings] || %{}))
    |> change(%{info: params[:info] || %{}})
  end

  def orgs(ids) do
    Repo.all(
      from o in Organization,
      where: o.id in ^ids
    )
  end

  def create(user, params) do
    params = Map.merge(params, %{"tenant" => get_tenant(params["name"])})

    cs = changeset(%Organization{}, params)
    cs = put_change(cs, :info, %{created_by: user.id})

    if cs.valid? do
      Repo.transaction fn ->
        {:ok, org} = Repo.insert(cs)
        {:ok, _user} = Publit.UserOrganization.add_user_org(user, org, %{"role" => "admin"})
        org
      end
    else
      {:error, cs}
    end
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
    |> Enum.map(fn(val) -> Publit.ListHelper.to_zip_to_map(resp.columns, val) end)

    {:ok, rows}
  end

  def users_map(org_id) do
    case users(org_id) do
      {:ok, usrs} ->
        Enum.into(usrs, %{}, fn(u) -> {u["id"], u} end)
    end
  end

  defp get_tenant(""), do: false
  defp get_tenant(nil), do: false
  defp get_tenant(name) do
    tenant = name
    |> String.strip
    |> String.downcase

    Regex.replace(~r/[^a-z]/i, tenant, "")
  end

end
