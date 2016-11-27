defmodule Publit.Order do
  use Publit.Web, :model
  alias Publit.{Order, OrderDetail, Product, Repo}
  import Ecto.Query
  import Publit.Gettext

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "orders" do
    field :user_id, Ecto.UUID
    field :organization_id, Ecto.UUID
    field :total, :decimal
    field :status, :string, default: "new"
    field :location, Geo.Geometry
    field :null_reason, :string
    field :number, :integer
    field :currency, :string
    field :extra_data, :map, default: %{}
    field :messages, {:array, :map}, default: []
    field :log, {:array, :map}, default: []

    embeds_many :details, OrderDetail, on_replace: :delete
    #field :messages, :list

    timestamps()
  end
  @statuses ["new", "process", "deliver", "delivered", "null"]


  @doc """
  Creates a new order with details
  """
  def create(params) do
    %Order{}
    |> cast(params, [:user_id, :organization_id, :location, :currency])
    |> validate_required([:user_id, :organization_id, :details, :location, :currency])
    |> cast_embed(:details)
    |> set_and_validate_details()
    |> set_total()
    |> set_number()
    |> add_log(%{time: Ecto.DateTime.autogenerate(), message: "Creation", type: "create", user_id: params["user_id"]})
    |> Repo.insert
  end

  @doc"""
  """
  def move_to_process(order, user_id) do
    Ecto.Changeset.change(order)
    |> put_change(:status, "process")
    |> add_log(%{type: "update", message: "Change to process", user_id: user_id})
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
    case Enum.find(products, fn(p) -> p.id == det_cs.changes.product_id end) do
      nil -> add_error(det_cs, :product_id, gettext("Invalid product"))
      prod ->
        det_cs = put_change(det_cs, :name, prod.name)
        case Enum.find(prod.variations, fn(var) -> var.id == det_cs.changes.variation_id end) do
          nil ->
            add_error(det_cs, :product_id, gettext("Invalid product"))
          var ->
            det_cs
            |> put_change(:variation, var.name)
            |> put_change(:price, var.price)
        end
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

end
