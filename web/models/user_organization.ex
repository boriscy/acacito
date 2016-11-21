defmodule Publit.UserOrganization do
  @moduledoc """
  This model has the attributes for a user that belongs to an organization
  """
  use Publit.Web, :model

  alias Publit.{Repo, UserOrganization}

  @derive {Poison.Encoder, only: [:id, :organization_id, :active, :role, :tenant, :name]}

  embedded_schema do
    field :organization_id, :binary
    field :active, :boolean, default: true
    field :role, :string, default: "user"
    field :name, :string

    timestamps
  end

  @roles ~w(admin user)


  @doc """
  Adds an organization to a user
  """
  @spec add(map, map, map) :: map
  def add(user, org, params \\ %{}) do
    case Enum.find(user.organizations, fn(org) -> org.organization_id == org.id end) do
      nil ->
        change(user)
        |> put_embed(:organizations, add_org(user, org, params))
        |> Repo.update()
      _org -> user
    end
  end

  defp add_org(user, org, params) do
    #Enum.map(user.organizations, fn(org) -> Ecto.Changeset.change(org) end) ++
    user.organizations ++ [changeset(org, params)]
  end

  defp changeset(org, params) do
    %UserOrganization{}
    |> cast(params, [:role])
    |> put_change(:organization_id, org.id)
    |> put_change(:name, org.name)
    |> validate_required([:role, :name])
    |> validate_inclusion(:role, @roles)
  end

  @doc """
  Updates data for a current organization
  """
  def update(user, org, params) do
    case Enum.find_index(user.organizations, fn(o) -> o.organization_id == org.id end) do
      nil ->
        {:error, user}
      idx ->
        u_org = update_organization(Enum.at(user.organizations, idx), params)
        Ecto.Changeset.change(user)
        |> put_embed(:organizations, List.update_at(user.organizations, idx, fn(_) -> u_org end))
        |> Repo.update()
    end
  end

  defp update_organization(user_org, params) do
    user_org
    |> cast(params, [:name, :role, :active])
    |> validate_required([:name, :role])
    |> validate_inclusion(:role, @roles)
    |> validate_inclusion(:active, [true, false])
  end

end
