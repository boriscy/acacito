defmodule Publit.UserTransport do
  use PublitWeb, :model
  use Publit.Account.Auth
  alias Publit.{UserTransport, Repo, Order}

  @email_reg ~r|^[\w0-9._%+-]+@[\w0-9.-]+\.[\w]{2,63}$|
  @number_reg ~r|^[6,7]\d{7}$|

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
    field :extra_data, :map, default: %{"status" => "listen"}
    field :mobile_number, :string
    field :plate, :string
    field :pos, Geo.Geometry
    field :status, :string, default: "off"
    field :vehicle, :string
    field :orders, Publit.Array, default: []
    field :verified, :boolean, default: false
    field :mobile_verification_token, :string
    field :mobile_verification_send_at, :naive_datetime

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
    |> cast(params, [:mobile_number, :full_name, :plate, :vehicle])
    |> validate_required([:mobile_number, :full_name])
    |> validate_format(:mobile_number, @number_reg)
    |> validate_inclusion(:vehicle, @vehicles)
    |> unique_constraint(:mobile_number)
    |> valid_transport()
    |> unique_constraint(:mobile_number)
  end

  def create(params) do
    cs = create_changeset(%UserTransport{}, params)

    if cs.valid? do
      Publit.UserUtil.create_and_set_verification_token(cs)
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
      |> update_trans_status()
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

  defp update_trans_status(cs) do
    with "transport" <- cs.data.extra_data["trans_status"],
      0 <- Repo.count(from o in orders_in_transport_query(cs.data.id), select: count(o.id)) do
        cs |>
        put_change(:extra_data, Map.put((cs.data.extra_data || %{}), "trans_status", "free"))
    else
      _ -> cs
    end
  end

  def orders_in_transport_query(id, ago \\ -3600 * 24) do
    from o in Order, where: o.user_transport_id == ^id and o.status in ["transport", "transporting", "process"]
    and o.inserted_at > ^NaiveDateTime.add(NaiveDateTime.utc_now, ago)
  end

  defp valid_transport(cs) do
    case Enum.any?(@vehicles_plate, fn(v) -> v === cs.changes[:vehicle] end) do
      true ->
        cs
        |> validate_required([:plate])
        |> validate_length(:plate, min: 3)
      _ -> cs
    end
  end

end
