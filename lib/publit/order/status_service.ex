defmodule Publit.Order.StatusService do
  use Publit.Web, :model
  alias Publit.{Order, UserTransport, Repo, User, UserTransport}
  alias Ecto.Multi
  import Publit.Gettext

  @token_id "device_token"

  @doc"""
  Changes the status of an order to the next
  """
  def next_status(%Order{status: "new"} = order, user) do
    log = %{"msg" => "Change status from new to process", "user_id" => user.id}
    update_status(order, "process", log, gettext("Yor order will be processed"))
  end
  def next_status(%Order{status: "process", transport: %Order.Transport{transport_type: "deliver"}} = order, user) do
    log = %{"msg" => "Change status from process to transport", "user_id" => user.id}
    update_status(order, "transport", log, gettext("Your order has transportation"))
  end

  def next_status(%Order{status: "process", transport: %Order.Transport{transport_type: "pickandpay"}} = order, user) do
    log = %{"msg" => "Change status from process to ready", "user_id" => user.id}
    update_status(order, "ready", log, gettext("Your order is ready"))
  end

  @doc """
  change Order from status `process` to `transport`
  it recognizes which kind of user makes the changes and passes the field :user or :user_client
  """
  def next_status(%Order{status: "transport"} = order, user) do
    log = %{"msg" => "Change status from transport to transporting", "user_id" => user.id}

    multi = Multi.new()
    |> Multi.update(:order, set_order_transport_status(order, "transporting", :picked_at, log))
    |> Multi.run(:log, fn(_) -> Order.Log.add(order.id, log) end)

    if order.user_transport_id do
      order = order |> Repo.preload([:user_transport])
      multi = Multi.update(multi, :user_transport, set_user_transport(order, order.user_transport, "transporting"))
    end

    case Repo.transaction(multi) do
      {:ok, res} ->
        send_message(res.order, gettext("Your order is on the way"))
        {:ok, res.order}
      {:error, res} ->
        {:error, res}
    end
  end

  def next_status(%Order{status: "transporting"} = order, %User{} = user) do
    log = %{"msg" => "Change status from transporting to delivered", "user_id" => user.id}

    multi = Multi.new()
    |> Multi.update(:order, set_order_transport_status(order, "delivered", :delivered_at, log))
    |> Multi.run(:log, fn(_) -> Order.Log.add(order.id, log) end)

    case Repo.transaction(multi) do
      {:ok, res} ->
        Publit.OrganizationChannel.broadcast_order(res.order, "order:updated")
        send_message_deliver(res.order)
        {:ok, res.order}
      {:error, cs} -> {:error, cs}
    end
  end
  def next_status(%Order{status: "transporting"} = order, %UserTransport{} = user) do
    log = %{"msg" => "Change status from transporting to delivered", "user_id" => user.id}

    multi = Multi.new()
    |> Multi.update(:order, set_order_transport_status(order, "delivered", :delivered_at, log))
    |> Multi.run(:log, fn(_) -> Order.Log.add(order.id, log) end)
    |> Multi.update(:user_transport, set_user_transport(order, user, "delivered"))

    case Repo.transaction(multi) do
      {:ok, res} ->
        Publit.OrganizationChannel.broadcast_order(res.order, "order:updated")
        send_message_deliver(res.order)
        {:ok, res.order}
      {:error, cs} -> {:error, cs}
    end
  end

  def next_status(%Order{status: "ready"} = order, %User{} = user) do
    log = %{"msg" => "Change status from ready to delivered", "user_id" => user.id}

    multi = Multi.new()
    |> Multi.update(:order, set_order_transport_status(order, "delivered", :delivered_at, log))
    |> Multi.run(:log, fn(_) -> Order.Log.add(order.id, log) end)

    case Repo.transaction(multi) do
      {:ok, res} ->
        Publit.OrganizationChannel.broadcast_order(res.order, "order:updated")
        send_message_deliver(res.order)
        {:ok, res.order}
      {:error, cs} -> {:error, cs}
    end
  end

  @doc"""
  Move to previous status
  """
  def previous_status(%Order{status: "process"} = order, user) do
    log = %{"msg" => "Change status from process to new", "user_id" => user.id }
    update_status(order, "new", log, "")
  end

  defp update_status(order, status, log, msg) do
    multi = Multi.new()
    |> Multi.update(:order, set_order_status(order, status))
    |> Multi.run(:log, fn(_) -> Order.Log.add(order.id, log) end)
    case Repo.transaction(multi) do
      {:ok, res} ->
        send_message(res.order, msg)
        {:ok, res.order}
      {:erro, res} -> {:error, res.order}
    end
  end

  defp set_order_status(order, status) do
    change(order)
    |> put_change(:status, status)
  end

  defp set_order_transport_status(order, status, field, opts) do
    dt = DateTime.to_string(DateTime.utc_now())
    tcs = change(order.transport) |> put_change(field, dt)

    change(order)
    |> put_change(:status, status)
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

        cs = change(ut)
        |> put_change(:orders, orders)
        if Enum.count(orders) <= 0 do
          cs |> put_change(:extra_data, Map.put(ut.extra_data, "trans_status", "listen") )
        else
          cs
        end
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

  defp send_message(order, msg) do
    order = Repo.preload(order, [:user_transport, :user_client])

    ord = Publit.TransApi.OrderView.to_api(order)
    cb_ok = fn(_) -> "" end
    cb_err = fn(_) -> "" end

    msg = %{
      message: msg,
      data: %{order: ord, status: "order:updated"}
    }
    if order.user_transport_id do
      tokens = [order.user_transport.extra_data[@token_id]]
      Publit.MessagingService.send_message_trans(tokens, msg, cb_ok, cb_err)
    end

    tokens = [order.user_client.extra_data[@token_id]]

    Publit.MessagingService.send_message_cli(tokens, msg, cb_ok, cb_err)
  end

  def send_message_deliver(order) do
    order = Repo.preload(order, [:user_client])

    tokens = [order.user_client.extra_data[@token_id]]

    {title, msg} = {gettext("Order delivered"), gettext("Your order has been delivered")}

    ord = Publit.TransApi.OrderView.to_api(order)
    cb_ok = fn(_) -> "" end
    cb_err = fn(_) -> "" end

    Publit.MessagingService.send_message_cli(tokens,
      %{title: title, message: msg, data: %{status: "order:updated", order: ord} },
      cb_ok, cb_err)
  end

end
