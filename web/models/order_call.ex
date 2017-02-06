defmodule Publit.OrderCall do
  use Publit.Web, :model
  import Ecto.Adapters.SQL
  alias Publit.{Order, OrderCall, UserTransport, Repo}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "order_calls" do
    field :transport_ids, Publit.Array, default: []
    field :status, :string, default: "new"

    belongs_to :order, Order, type: :binary_id
    timestamps()
  end
  @statuses ["new", "delivered", "error"]

  def create(order, organization, radius \\ 1000) do
    {lng, lat} = organization.pos.coordinates
    transports = get_user_transports(%{"coordinates" => [lng, lat]})
    tokens = Enum.map(transports, fn(t) -> t.extra_data["fb_token"] end)
    ids = Enum.map(transports, fn(t) -> t.id end)

    cb = fn(v) -> end
    #Publit.MessagingService.messages(tokens, %{}, cb)
    oc = %OrderCall{order_id: order.id, transport_ids: ids}
    Repo.insert(oc)
  end

  def update(order_call, params) do
    order_call
    |> cast(params, [:status])
    |> validate_inclusion(:status, ["delivered", "ok"])
    |> Repo.update()
  end

  # Gets all near transports within radius kilometers
  def get_user_transports(params, radius \\ 1000) do
    [lng, lat] = params["coordinates"]

    q = from ut in UserTransport, where: ut.status == "listen"
      and fragment("ST_DISTANCE_SPHERE(?, ST_MakePoint(?, ?)) <= ?", ut.pos, ^lng, ^lat, ^radius)

    Repo.all(q)
  end

end
