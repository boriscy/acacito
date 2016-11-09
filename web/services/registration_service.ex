defmodule Publit.RegistrationService do
  use Ecto.Schema
  import Ecto.Changeset
  alias Publit.{RegistrationService, Organization, User, UserOrganization, Repo}
  alias Ecto.Multi

  embedded_schema do
    field :email
    field :password
    field :name
    field :category, :string, default: "restaurant"
    field :address
  end

  @categories ["restaurant", "store"]
  @email_reg ~r|^[\w0-9._%+-]+@[\w0-9.-]+\.[\w]{2,63}$|

  @doc """
  Creates the user, organization and user_organization
  """
  def register(params) do
    cs = changeset(params)

    case cs.valid? do
      true ->
        multi = Multi.new
        |> Multi.insert(:org, %Organization{name: cs.changes.name})
        |> Multi.run(:user_org, fn(%{org: org}) -> set_user_multi(cs, org) end)
        |> Multi.merge(&create_user_multi/1)

        Repo.transaction(multi)
      false -> cs
    end
  end

  defp set_user_multi(cs, org) do
    {:ok, %User{
        email: cs.changes.email,
        organizations: [%UserOrganization{
          name: org.name,
          organization_id: org.id,
          active: true,
          role: "admin"
        }]
      }
    }
  end

  defp create_user_multi(data) do
    Multi.new |> Multi.insert(:user, data[:user_org])
  end

  def changeset(params) do
    cs = %RegistrationService{}
    |> cast(params, [:email, :password, :name, :category, :address])
    |> validate_required([:email, :password, :name, :category, :address])
    |> validate_format(:email, @email_reg)
    |> validate_length(:password, min: 8)
    |> validate_inclusion(:category, @categories)
  end

end
