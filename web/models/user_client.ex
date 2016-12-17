defmodule Publit.UserClient do
  use Publit.Web, :model
  alias Publit.{UserClient, Repo}

  @email_reg ~r|^[\w0-9._%+-]+@[\w0-9.-]+\.[\w]{2,63}$|
  @number_reg ~r|^\d{8}$|

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :email, :string
    field :full_name, :string
    field :encrypted_password, :string
    field :locale, :string, default: "es"
    field :settings, :map, default: %{}
    field :mobile_number, :string
    field :type, :string, default: "client"

    field :password, :string, virtual: true

    timestamps()
  end
  @derive {Poison.Encoder, only: [:id, :full_name, :email, :mobile_number]}

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :full_name, :password, :mobile_number])
    |> validate_required([:email, :password, :full_name, :mobile_number])
    |> validate_format(:email, @email_reg)
    |> validate_format(:mobile_number, @number_reg)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
  end

  def create(params) do
    cs = create_changeset(%UserClient{}, params)

    if cs.valid? do
      cs = Publit.User.generate_encrypted_password(cs)
      Repo.insert(cs)
    else
      {:error , cs}
    end
  end

end