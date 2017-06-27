defmodule Publit.Order.Query do
  import Ecto.Query
  alias Publit.{Order, Repo}

  @limit 25

  # Query methods
  @doc """
  Returns the active orders ["new", "process", "transport"] for the current organization
  """
  def active(organization_id) do
    q = from o in Order,
    where: o.organization_id == ^organization_id and o.status in ["new", "process", "transport", "transporting", "ready"]

    Repo.all(q) |> Repo.preload(:user_client)
  end

  # Returns the organization order
  def get_order(order_id, org_id) do
    Repo.one(from o in Order, where: o.id == ^order_id and o.organization_id == ^org_id)
  end

  def user_orders(user_client_id) do
    q = from o in Order, where: o.user_client_id == ^user_client_id, order_by: [desc: o.inserted_at], limit: @limit

    Repo.all(q)
  end

  def user_active_orders(user_client_id) do
    q = from o in Order, where: o.user_client_id == ^user_client_id,
      where: o.status in ^["new", "process", "transport", "transporting"], order_by: [desc: o.inserted_at]

    Repo.all(q)
  end

  def transport_orders(ut_id, statuses \\ ["transport", "transporting"]) do
    q = from o in Order, where: o.user_transport_id == ^ut_id and o.status in ^statuses, order_by: [desc: o.inserted_at]

    Repo.all(q)
  end
end
