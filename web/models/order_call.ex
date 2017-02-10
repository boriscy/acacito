defmodule Publit.OrderCall do
  use Publit.Web, :model
  import Ecto.Adapters.SQL
  alias Publit.{Order, OrderCall, UserTransport, Repo}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "order_calls" do
    field :transport_ids, Publit.Array, default: []
    field :status, :string, default: "new"
    field :resp, :map

    belongs_to :order, Order, type: :binary_id
    timestamps()
  end
  #@statuses ["new", "delivered", "error"]

  @doc """
  Creates and %OrderCall{} and stores in the db when correct then
  it sends messages to all near transports with  `status: calling`
  """
  def create(order, radius \\ 1000) do
    {lng, lat} = order.organization_pos.coordinates
    transports = get_user_transports(%{"coordinates" => [lng, lat]}, radius)

    if Enum.count(transports) > 0 do
      ids = Enum.map(transports, fn(t) -> t.id end)
      oc = %OrderCall{order_id: order.id, transport_ids: ids}

      tokens = Enum.map(transports, fn(t) -> t.extra_data["fb_token"] end)

      create_and_send_messages(oc, order, tokens)
    else
      {:empty, %OrderCall{}}
    end
  end

  defp create_and_send_messages(oc, order, tokens) do
    case Repo.insert(oc) do
      {:ok, oc} ->
        cb_ok = fn(resp) -> OrderCall.update(oc, %{status: "delivered", resp: Map.drop(resp.resp, [:__struct__])}) end
        cb_error = fn(resp) -> OrderCall.update(oc, %{status: "error", resp: Map.drop(resp.resp, [:__struct__]) }) end

        {:ok, pid} = Publit.MessagingService.send_messages(tokens, %{order_id: oc.order_id, status: "calling"}, cb_ok, cb_error)

        {:ok, oc, pid}
      {:error, cs} ->
        {:error, cs}
    end
  end

  defp encode_order(order) do
    Map.take(order, [:a])
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

end
