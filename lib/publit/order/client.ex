defmodule Publit.Order.Client do
  use Publit.Web, :model
  alias Publit.{Order, Repo}

  @primary_key false
  embedded_schema do
    field :name, :string
    field :address, :string
    field :mobile_number, :string
    field :orders, :integer
    field :nulled_orders, :integer
  end

  def changeset_create(%Publit.UserClient{} = uc, cs) do
    params = cs.params["cli"] || %{}

    cs = cast(%Order.Client{
      name: uc.full_name, mobile_number: uc.mobile_number,
      nulled_orders: count_nulled(uc.id), orders: count_orders(uc.id, "delivered")
    }, cs.params, [:address])

    if cs.params["trans"] && "delivery" === cs.params["trans"]["ctype"] do
      cs
      |> cast(params, [:address])
      |> validate_required([:address])
      |> validate_length(:address, min: 8)
    else
      cs
    end
  end

  def count_orders(id, status \\ "delivered") do
    q = from o in Order,
    where: o.user_client_id == ^id and o.status == ^status,
    select: count(o.id)

    Repo.one(q)
  end

  def count_nulled(id) do
    q = from o in Order,
    where: o.user_client_id == ^id and o.status == "nulled"
    and o.prev_status in ["process", "transport", "transporting", "ready"],
    select: count(o.id)

    Repo.one(q)
  end

end
