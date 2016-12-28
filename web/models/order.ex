defmodule Publit.Order do
  use Publit.Web, :model
  alias Publit.{Order, User, OrderDetail, Product, Repo}
  import Ecto.Query
  import Publit.Gettext

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "orders" do
    field :user_id, Ecto.UUID
    field :organization_id, Ecto.UUID
    field :total, :decimal
    field :status, :string, default: "new"
    field :location, Geo.Geometry # Location is stored
    field :null_reason, :string
    field :number, :integer
    field :currency, :string
    field :transport, :map, default: %{}
    field :messages, {:array, :map}, default: []
    field :log, {:array, :map}, default: []

    embeds_many :details, OrderDetail, on_replace: :delete
    #field :messages, :list

    timestamps()
  end
  @statuses ["new", "process", "transport", "delivered", "null"]


  @doc"""
  return orders with status "new", "process" and "transport"
  """
  def all(organization_id) do
    q = from o in Order, where: o.status in ^["new", "process", "transport"] and o.organization_id == ^organization_id
    Repo.all(q)
  end

  @doc """
  Creates a new order with details
  """
  def create(params) do
    cs = %Order{}
    |> cast(params, [:user_id, :organization_id, :location, :currency])
    |> validate_required([:user_id, :organization_id, :details, :location, :currency])
    |> cast_embed(:details)
    |> set_and_validate_details()
    if cs.valid? do
      cs
      |> set_total()
      |> set_number()
      |> add_log(%{time: Ecto.DateTime.autogenerate(), message: "Creation", type: "create", user_id: params["user_id"]})
      |> Repo.insert()
    else
      {:error, cs}
    end
  end

  @doc"""
  Changes the status of an order to the next
  """
  def next_status(%Order{status: "new"} = order, user_id) do
    update_status(order, "process", message: "Change status to process", type: "update_next", user_id: user_id)
  end
  def next_status(%Order{status: "process"} = order, user_id) do
    update_status(order, "transport", message: "Change status to transport", type: "update_next", user_id: user_id)
  end
  def next_status(%Order{status: "transport"} = order, user_id) do
    update_status(order, "delivered", message: "Change status to delivered", type: "update_next", user_id: user_id)
  end

  @doc"""
  Move to previous status
  """
  def previous_status(%Order{status: "process"} = order, user_id) do
    update_status(order, "new", message: "Back to status new", user_id: user_id, type: "update_back")
  end

  def to_api(order) do
    {lat, lng} = order.location.coordinates
    order
    |> Map.delete(:__meta__)
    |> Map.put(:location, Geo.JSON.encode(order.location))
  end

  defp update_status(order, status, opts) do
    Ecto.Changeset.change(order)
    |> put_change(:status, status)
    |> add_log(%{type: opts[:type], message: opts[:message], user_id: opts[:user_id], time: Ecto.DateTime.autogenerate() })
    |> Repo.update()
  end

  defp set_number(cs) do
    dt = Ecto.DateTime.autogenerate()
    d = Ecto.DateTime.to_date(dt)
    q = from(o in Order, where: o.organization_id == ^cs.changes.organization_id
     and fragment("date(?)", o.inserted_at) == ^d, select: count(o.id))

    num = Repo.one(q) + 1

    cs
    |> put_change(:inserted_at, dt)
    |> put_change(:number, num)
  end

  defp add_log(cs, msg) do
    cs |> put_change(:log, List.insert_at(cs.data.log, -1, msg))
  end

  defp set_and_validate_details(cs) do
    products = get_products(cs)

    details = cs.changes.details
    |> Enum.map(fn(det_cs) -> set_product_and_variation(det_cs, products) end)

    put_embed(cs, :details, details)
  end

  defp set_product_and_variation(det_cs, products) do
    with prod <- Enum.find(products, fn(p) -> p.id == det_cs.changes.product_id end),
      true <- !is_nil(prod),
      var <- Enum.find(prod.variations, fn(var) -> var.id == det_cs.changes.variation_id end),
      true <- !is_nil(var) do
        det_cs
        |> put_change(:name, prod.name)
        |> put_change(:variation, var.name)
        |> put_change(:price, var.price)
    else
      false ->
        add_error(det_cs, :product_id, gettext("Invalid product"))
    end
  end

  defp get_products(cs) do
    ids = cs.changes.details |> Enum.map(fn(det) -> det.changes.product_id end)

    q = from p in Product, where: p.id in ^ids and p.organization_id == ^cs.changes.organization_id and p.publish == true
    Repo.all(q)
  end

  defp set_total(cs) do
    tot = cs.changes.details
    |> Enum.reduce(Decimal.new("0"), fn(det, acc) ->
      Decimal.add(acc, Decimal.mult(det.changes.quantity, det.changes.price) )
    end)

    put_change(cs, :total, tot)
  end

  def active(organization_id) do
    q = from o in Order, join: u in User,
    select: %{id: o.id, details: o.details, client: u.full_name, location: o.location,
     inserted_at: o.inserted_at, updated_at: o.updated_at, total: o.total,
     status: o.status, number: o.number},
    where: o.organization_id == ^organization_id and o.status in ["new", "process", "transport"] and o.user_id == u.id
    Repo.all(q)
  end

end
