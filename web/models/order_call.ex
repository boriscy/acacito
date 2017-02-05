defmodule Publit.OrderCall do
  use Publit.Web, :model
  import Ecto.Adapters.SQL
  alias Publit.{Order, UserTransport, Repo}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "order_calls" do
    field :transport_ids, Publit.Array, default: []

    belongs_to :order, Order, type: :binary_id
    timestamps()
  end

  def create(order) do
  end

  # Gets all near transports within radius kilometers
  def get_user_transports(params, radius \\ 1000) do
    [lng, lat] = params["coordinates"]

    q = from ut in UserTransport, select: [:id], where: ut.status == "listen"
      and fragment("ST_DISTANCE_SPHERE(?, ST_MakePoint(?, ?)) <= ?", ut.pos, ^lng, ^lat, ^radius)

    Repo.all(q)
  end

end
