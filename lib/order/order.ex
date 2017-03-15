defmodule Publit.Order do
  use Publit.Web, :model
  alias Publit.{Order, Order.Call, Order.Transport, UserClient, UserTransport, Order.Detail, Product, Organization, Repo}
  alias Ecto.Multi
  import Ecto.Query
  import Publit.Gettext

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "orders" do
    field :total, :decimal
    field :status, :string, default: "new"
    field :null_reason, :string
    field :num, :integer
    field :currency, :string
    field :client_pos, Geo.Geometry
    field :organization_pos, Geo.Geometry
    field :organization_name, :string
    field :client_name, :string

    embeds_one :transport, Order.Transport
    embeds_many :details, Order.Detail

    belongs_to :user_client, UserClient, type: :binary_id
    belongs_to :user_transport, UserTransport, type: :binary_id
    belongs_to :organization, Organization, type: :binary_id

    has_many :order_calls, Order.Call
    has_one :log, Order.Log
    has_one :chat, Order.Chat

    timestamps()
  end
  @statuses ["new", "process", "transport", "transporting", "delivered", "nulled"]


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
    |> cast(params, [:user_client_id, :client_pos, :client_name, :currency, :organization_id])
    |> validate_required([:user_client_id, :details, :client_pos, :currency, :client_name])
    |> cast_embed(:details)
    |> set_and_validate_details()

    with true <- cs.valid? do
      cs
      |> set_organization()
      |> set_transport()
      |> set_total()
      |> set_num()
      |> put_assoc(:log, %Order.Log{})
      |> put_assoc(:chat, %Order.Chat{})
      |> Repo.insert()
    else
      _ ->
        {:error, cs}
    end
  end

  def set_order_create(cs) do
    cs
    |> set_total()
    |> set_num()
  end

  defp set_num(cs) do
    d = Ecto.Date.utc()

    {:ok, org_id} = Ecto.UUID.cast(cs.params["organization_id"])
    q = from(o in Order, where: o.organization_id == ^org_id
     and fragment("date(?)", o.inserted_at) == ^d, select: count(o.id))

    num = Repo.one(q) + 1

    cs
    |> put_change(:num, num)
  end

  def add_log(cs, msg) do
    msg = Map.put(msg, :time, DateTime.utc_now())

    cs |> put_change(:log, List.insert_at(cs.data.log, -1, msg) )
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
    q = from p in Product, where: p.id in ^ids and p.organization_id == ^cs.params["organization_id"] and p.publish == true
    Repo.all(q)
  end

  defp set_total(cs) do
    tot = cs.changes.details
    |> Enum.reduce(Decimal.new("0"), fn(det, acc) ->
      Decimal.add(acc, Decimal.mult(det.changes.quantity, det.changes.price) )
    end)

    put_change(cs, :total, tot)
  end

  defp set_transport(cs) do
    if cs.changes.organization_id do
      p = Map.merge(cs.params["transport"] || %{"calculated_price" => ""}, %{})

      cs
      |> put_change(:organization_pos, cs.changes.organization.data.pos)
      |> Map.put(:params, Map.merge(cs.params, %{"transport" => p}) )
      |> cast_embed(:transport)
    else
      cs
    end
  end

  defp set_organization(cs) do
    org = Repo.get(Organization, cs.changes[:organization_id])
    cs
    |> put_assoc(:organization,  org)
    |> put_change(:organization_name, org.name)
  end

end