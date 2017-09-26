defmodule Publit.UserClient do
  use PublitWeb, :model
  use Publit.Account.Auth
  alias Publit.{UserClient, Repo}

  @email_reg ~r|^[\w0-9._%+-]+@[\w0-9.-]+\.[\w]{2,63}$|
  @number_reg ~r|^[6,7]\d{7}$|

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
    field :mobile_verification_token, :string
    field :mobile_verification_send_at, :naive_datetime

    field :password, :string, virtual: true

    timestamps()
  end
  @derive {Poison.Encoder, only: [:id, :full_name, :email, :mobile_number]}

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """

  def create(params) do
    cs = create_changeset(%UserClient{}, params)

    if cs.valid? do
      Publit.UserUtil.create_and_set_verification_token(cs)
    else
      {:error , cs}
    end
  end

end
