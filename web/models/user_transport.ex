defmodule Publit.UserTransport do
  use Publit.Web, :model
  use Publit.Device
  alias Publit.{UserTransport, Repo}

  @email_reg ~r|^[\w0-9._%+-]+@[\w0-9.-]+\.[\w]{2,63}$|
  @number_reg ~r|^\d{8}$|

  #defmodule Order do
  #  defstruct [:id, :status]
  #end

  @derive {Poison.Encoder, only: [:id, :full_name, :email, :mobile_number, :status]}
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "user_transports" do
    field :email, :string
    field :full_name, :string
    field :encrypted_password, :string
    field :locale, :string, default: "es"
    field :settings, :map, default: %{}
    field :extra_data, :map, default: %{}
    field :mobile_number, :string
    field :plate, :string
    field :pos, Geo.Geometry
    field :status, :string, default: "off"
    field :vehicle, :string
    field :orders, Publit.Array, default: []

    field :password, :string, virtual: true

    timestamps()
  end
  @statuses ["off", "listen", "order"]
  @vehicles ["walk", "bike", "motorcycle", "car", "truck"]
  @vehicles_plate ["motorcycle", "car", "truck"]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:mobile_number, :email, :full_name, :password, :plate, :vehicle])
    |> validate_required([:password, :full_name, :mobile_number, :vehicle])
    |> validate_format(:email, @email_reg)
    |> validate_format(:mobile_number, @number_reg)
    |> validate_length(:password, min: 8)
    |> validate_inclusion(:vehicle, @vehicles)
    |> unique_constraint(:mobile_number)
    |> valid_transport()
    |> unique_constraint(:email)
  end

  def create(params) do
    cs = create_changeset(%UserTransport{}, params)

    if cs.valid? do
      cs = Publit.User.generate_encrypted_password(cs)
      Repo.insert(cs)
    else
      {:error , cs}
    end
  end

  def update() do

  end

  #@type update_position(%UserTransport, map) tuple
  def update_position(user, params) do
    user
    |> cast(params, [:pos])
    |> put_change(:status, "listen")
    |> validate_required([:pos])
    |> valid_position()
    |> Repo.update()
  end

  def stop_tracking(user) do
    if user.status == "listen" do
      user
      |> change()
      |> put_change(:status, "off")
      |> Repo.update()
    else
      cs = user |> change() |> add_error(:status, "Invalid status")
      {:error, cs}
    end
  end

  defp valid_position(cs) do
    with {:pos, true} <- {:pos, !!cs.changes[:pos]},
      %Geo.Point{coordinates: {lng, lat}} <- cs.changes.pos,
      {:num, true} <- {:num, (is_number(lng) && is_number(lat) )},
      {:range, true} <- {:range, (lng >= -180 && lng <= 180 && lat >= -90 && lat <= 90)}
       do
        cs
    else
      _ ->
        add_error(cs, :pos, "Invalid position")
    end
  end

  defp valid_transport(cs) do
    case Enum.any?(@vehicles_plate, fn(v) -> v == cs.changes[:vehicle] end) do
      true ->
        cs
        |> validate_required([:plate])
        |> validate_length(:plate, min: 3)
      _ -> cs
    end
  end

end
