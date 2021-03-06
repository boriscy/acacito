defmodule Publit.RegistrationService do
  use Ecto.Schema
  import Ecto.Changeset
  import PublitWeb.Gettext
  alias Publit.{RegistrationService, Organization, User, UserOrganization, Repo}
  alias Ecto.Multi

  embedded_schema do
    field :email
    field :password
    field :name
    field :full_name
    field :mobile_number
    field :category, :string, default: "restaurant"
    field :address
  end

  @categories ["restaurant", "store"]
  @email_reg ~r|^[\w0-9._%+-]+@[\w0-9.-]+\.[\w]{2,63}$|
  @number_reg ~r|^591[6,7]\d{7}$|

  @doc """
  Creates the user, organization and user_organization
  """
  def register(params) do
    cs = changeset(params)

    case cs.valid? do
      true ->
        multi = Multi.new
        |> Multi.insert(:org, %Organization{name: cs.changes.name, address: cs.changes.address, mobile_number: cs.changes.mobile_number})
        |> Multi.run(:user_org, fn(%{org: org}) -> set_user_multi(cs.changes, org) end)
        |> Multi.merge(&create_user_multi/1)

        Repo.transaction(multi)
      false ->
        {:error, cs}
    end
  end

  defp set_user_multi(changes, org) do
    cs = Ecto.Changeset.change(%User{}, changes)
    |> put_embed(:organizations, [%UserOrganization{
          name: org.name, organization_id: org.id,
          active: true, role: "admin"
        }])
    |> unique_constraint(:email)
    |> unique_constraint(:mobile_number)

    cs = if cs.valid? do
      pw = Comeonin.Bcrypt.hashpwsalt(cs.changes.password)
      cs = cs |> put_change(:encrypted_password, pw)
    end

    {:ok, cs}
  end

  defp create_user_multi(data) do
    Multi.new |> Multi.insert(:user, data[:user_org])
  end

  def changeset(params) do
    %RegistrationService{}
    |> cast(params, [:email, :mobile_number, :password, :name, :full_name, :category, :address])
    |> validate_required([:email, :mobile_number, :password, :name, :full_name, :category, :address])
    |> validate_format(:email, @email_reg)
    |> validate_format(:mobile_number, @number_reg)
    |> validate_length(:password, min: 8, message: err_gettext("should be at least %{count} character(s)", count: 8))
    |> validate_length(:address, min: 8, message: err_gettext("should be at least %{count} character(s)", count: 8))
    |> validate_length(:full_name, min: 5, message: err_gettext("should be at least %{count} character(s)", count: 3))
    |> validate_inclusion(:category, @categories)
  end

end
