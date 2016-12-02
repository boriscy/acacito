defmodule Publit.User do
  use Publit.Web, :model
  alias Publit.{User, UserOrganization, Repo}


  @email_reg ~r|^[\w0-9._%+-]+@[\w0-9.-]+\.[\w]{2,63}$|

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :email, :string
    field :full_name, :string
    field :encrypted_password, :string
    field :locale, :string, default: "es"
    field :settings, :map, default: %{}
    field :extra_data, :map, default: %{}

    field :password, :string, virtual: true

    embeds_many :organizations, UserOrganization, on_replace: :delete

    timestamps()
  end
  @derive {Poison.Encoder, only: [:id, :full_name, :email]}

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :full_name, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, @email_reg)
    |> validate_length(:password, min: 8)
    |> unique_constraint(:email)
  end

  def create(params) do
    cs = create_changeset(%User{}, params)

    if cs.valid? do
      cs = generate_encrypted_password(cs)
      Repo.insert(cs)
    else
      {:error , cs}
    end
  end

  defp generate_encrypted_password(cs) do
    case cs do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(cs, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        cs
    end
  end

end
