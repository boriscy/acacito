defmodule Publit.Order.Call do
  use Publit.Web, :model
  import Ecto.Adapters.SQL
  alias Publit.{Order, Order.Call, UserTransport, Repo}
  import Publit.Gettext

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "order_calls" do
    field :transport_ids, Publit.Array, default: []
    field :status, :string, default: "new"
    field :resp, :map

    belongs_to :order, Order, type: :binary_id
    timestamps()
  end
  #@statuses ["new", "delivered", "error"]

  @token_id "device_token"

  @doc """
  Creates and %Order.Call{} and stores in the db when correct then
  it sends messages to all near transports with  `status: calling`
  """
  def create(order, radius \\ 1_000) do
    {lng, lat} = order.organization_pos.coordinates
    transports = get_user_transports(%{"coordinates" => [lng, lat]}, radius)

    if Enum.count(transports) > 0 do
      ids = Enum.map(transports, fn(t) -> t.id end)
      occs = %Order.Call{order_id: order.id, transport_ids: ids}
      |> change()
      |> put_assoc(:order, order)

      tokens = Enum.map(transports, fn(t) -> t.extra_data[@token_id] end)

      create_and_send_message(occs, tokens)
    else
      {:empty, %Order.Call{}}
    end
  end

  defp create_and_send_message(occs, tokens) do
    case Repo.insert(occs) do
      {:ok, oc} ->
        cb_ok = fn(resp) -> Order.Call.update(oc, %{status: "delivered", resp: Map.drop(resp.resp, [:__struct__])}) end
        cb_error = fn(resp) -> Order.Call.update(oc, %{status: "error", resp: Map.drop(resp.resp, [:__struct__]) }) end

        msg = %{
          message: gettext("New order from %{org}", %{org: oc.order.organization_name}),
          data: %{
            status: "calling",
            order_call: encode(oc)
          }
        }

        {:ok, pid} = Publit.MessagingService.send_message_trans(tokens, msg, cb_ok, cb_error)

        {:ok, oc, pid}
      {:error, cs} ->
        {:error, cs}
    end
  end

  def update(order_call, params) do
    params = put_in(params, [:resp, :headers], Enum.into(params.resp[:headers], %{}, fn({a, b}) -> {a, b} end) )

    order_call
    |> cast(params, [:status, :resp])
    |> validate_inclusion(:status, ["delivered", "error"])
    |> Repo.update()
  end

  # Gets all near transports within radius kilometers
  def get_user_transports(params, radius \\ 1000) do
    [lng, lat] = params["coordinates"]

    q = from ut in UserTransport, where: ut.status == "listen"
      and fragment("ST_DISTANCE_SPHERE(?, ST_MakePoint(?, ?)) <= ?", ut.pos, ^lng, ^lat, ^radius)

    Repo.all(q)
  end

  def encode(oc) do
    oc
    |> Map.drop([:__meta__, :__struct__])
    |> Map.put(:order, Publit.OrderView.to_api(oc.order) )
  end

  def delete(order_id) do
    Repo.delete_all(from oc in Order.Call, where: oc.order_id == ^order_id and oc.status in ^["new", "delivered"])
  end

end
