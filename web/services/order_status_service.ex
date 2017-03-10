defmodule Publit.OrderStatusService do
  use Publit.Web, :model
  alias Publit.{Order, UserTransport, Repo, User, UserTransport}
  alias Ecto.Multi
  import Publit.Gettext

  @doc"""
  Changes the status of an order to the next
  """
  def next_status(%Order{status: "new"} = order, user) do
    update_status(order, "process", %{msg: "Change status from new to process", type: "update:order.status", user_id: user.id})
  end
  def next_status(%Order{status: "process"} = order, user) do
    update_status(order, "transport", %{msg: "Change status from process to transporting", type: "update:order.status", user_id: user.id})
  end
  @doc """
  change Order from status `process` to `transport`
  it recognizes which kind of user makes the changes and passes the field :user or :user_client
  """
  def next_status(%Order{status: "transport"} = order, %User{} = user), do: next_status(order, user, :user)
  def next_status(%Order{status: "transport"} = order, %UserTransport{} = user), do: next_status(order, user, :user_client)
  defp next_status(%Order{status: "transport"} = order, user, user_type) do
    log = %{msg: "Change status from transport to transporting", type: "update:order.status"}
    |> Map.put(user_type, user.id)

    multi = Multi.new()
    |> Multi.update(:order, set_order_transport_status(order, "transporting", :picked_at, log))
    |> Multi.update(:user_transport, set_user_transport(order, user, "transporting"))

    case Repo.transaction(multi) do
      {:ok, res} -> {:ok, res.order}
      {:error, res} -> {:error, res}
    end
  end

  def next_status(%Order{status: "transporting"} = order, %User{} = user) do
    log = %{msg: "Change status from transporting to delivered", type: "update:order.status"}
    |> Map.put(:user_id, user.id)

    change(order)
    |> put_change(:status, "delivered")
    |> Order.add_log(log)
    |> Repo.update()
  end
  def next_status(%Order{status: "transporting"} = order, %UserTransport{} = user) do
    log = %{msg: "Change status from transporting to delivered", type: "update:order.status"}
    |> Map.put(:user_transport_id, user.id)

    multi = Multi.new()
    |> Multi.update(:order, set_order_transport_status(order, "delivered", :delivered_at, log))
    |> Multi.update(:user_transport, set_user_transport(order, user, "delivered"))

    case Repo.transaction(multi) do
      {:ok, res} -> {:ok, res.order}
      {:error, cs} -> {:error, cs}
    end
  end

  @doc"""
  Move to previous status
  """
  def previous_status(%Order{status: "process"} = order, user_id) do
    update_status(order, "new", %{msg: "Change status from process to new", user_id: user_id, type: "update:order.status"})
  end

  defp update_status(order, status, log) do
    set_order_status(order, status, log)
    |> Repo.update()
  end

  defp set_order_status(order, status, log) do
    change(order)
    |> put_change(:status, status)
    |> Order.add_log(log)
  end

  defp set_order_transport_status(order, status, field, opts) do
    dt = DateTime.to_string(DateTime.utc_now())
    tcs = change(order.transport) |> put_change(field, dt)

    change(order)
    |> put_change(:status, status)
    |> Order.add_log(%{type: opts[:type], message: opts[:message], user_id: opts[:user_id], time: Ecto.DateTime.autogenerate() })
    |> put_embed(:transport, tcs)
  end

  defp set_user_transport(order, ut, "transporting") do
    case get_user_transport_order_index(order, ut) do
      {:ok, idx} ->
        orders = List.update_at(ut.orders, idx, fn(o) -> Map.put(o, "status", "transporting") end)

        change(ut)
        |> put_change(:orders, orders)
      :error ->
        change(%UserTransport{})
        |> add_error(:orders, gettext("User transport not found"))
    end
  end

  defp set_user_transport(order, ut, "delivered") do
    case get_user_transport_order_index(order, ut) do
      {:ok, idx} ->
        orders = List.delete_at(ut.orders, idx)

        change(ut)
        |> put_change(:orders, orders)
      :error ->
        change(ut)
        |> add_error(:orders, gettext("Order not found"))
    end
  end

  defp get_user_transport_order_index(order, ut) do
    with idx <- Enum.find_index(ut.orders, fn(o) -> o["id"] == order.id end),
      {:idx, true} <- {:idx, is_number(idx)} do
        {:ok, idx}
    else
      _ -> :error
    end
  end

end
