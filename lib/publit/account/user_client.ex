defmodule Publit.UserClient do
  use PublitWeb, :model
  use Publit.Device
  alias Publit.{UserClient, Repo}

  @email_reg ~r|^[\w0-9._%+-]+@[\w0-9.-]+\.[\w]{2,63}$|
  @number_reg ~r|^591[6,7]\d{7}$|

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "user_clients" do
    field :email, :string
    field :full_name, :string
    field :encrypted_password, :string
    field :locale, :string, default: "es"
    field :settings, :map, default: %{}
    field :extra_data, :map, default: %{}
    field :mobile_number, :string
    field :verified, :boolean, default: false

    field :password, :string, virtual: true

    field :mobile_verification_token, :string
    field :mobile_verification_send_at, :naive_datetime

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
    |> unique_constraint(:mobile_number)
  end

  def create_cs(struct, params \\ %{}) do
    struct
    |> cast(params, [:full_name, :mobile_number])
    |> validate_required([:full_name, :mobile_number])
    |> validate_format(:mobile_number, @number_reg)
    |> unique_constraint(:mobile_number)
  end

  def create(params) do
    cs = create_cs(%UserClient{}, params)

    if cs.valid? do
      Publit.UserUtil.create_and_set_verification_token(cs)
    else
      {:error , cs}
    end
  end

end
