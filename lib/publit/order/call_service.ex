defmodule Publit.Order.CallService do
  use Publit.Web, :model
  import Ecto.Query
  import Publit.Gettext
  alias Ecto.Multi

  alias Publit.{Order, Repo}

  @token_id "device_token"

  @moduledoc """
  This module handles the call and updates both Order and Order.Call as well as it sends
  notifications to all UserTransport that have received
  """

  def accept(order, ut, params) do
    q = from order_call_query(order), limit: 1

    case Repo.one(q) do
      nil -> :empty
      oc ->
        multi = Multi.new()
        |> Multi.update(:order, set_order_cs(order, ut, params))
        |> Multi.run(:log, fn(_) -> Order.Log.add(order.id, %{"msg" => "Order call accepted", "user_id" => ut.id}) end)
        |> Multi.update(:user_transport, set_user_transport_cs(order, ut))
        |> Multi.delete_all(:order_call, order_call_query(order, ["new", "delivered"]))

        case Repo.transaction(multi) do
          {:ok, res} ->
            {:ok, pid} = send_message(oc, res.order)
            {:ok, res.order, pid}
          {:error, :order, cs, _} ->
            {:error, :order, cs}
        end
    end
  end

  #@doc """
  #Receives a %Order{} and %UserTransport{} to update the order
  #"""
  defp set_order_cs(order, ut, %{final_price: fp}) do
    change(order)
    |> put_change(:status, "transport")
    |> put_change(:user_transport_id, ut.id)
    |> put_embed(:trans, Order.Transport.changeset_update(order.trans, ut, %{final_price: fp}))
  end

  defp order_call_query(order, statuses \\ ["delivered"]) do
    from oc in Order.Call, where: oc.order_id == ^order.id and oc.status in ^statuses
  end

  defp send_message(oc, order) do
    uts = Repo.all(from ut in Publit.UserTransport, where: ut.id in ^oc.transport_ids)
    tokens = Enum.map(uts, fn(t) -> t.extra_data[@token_id] end)

    cb_ok = fn(_) -> "" end
    cb_err = fn(resp) -> log_error(resp) end

    msg = %{
      message: gettext("New order from %{org}", org: order.org.name),
      data: %{
        order_call_id: oc.id,
        order: Publit.TransApi.OrderView.to_api(order)
      }
    }

    Publit.MessagingService.send_message_trans(tokens, msg, cb_ok, cb_err)
    order = Repo.preload(order, :user_client)
    token = order.user_client.extra_data["device_token"]
    msg = %{
      message: gettext("Your order has transportation"),
      data: %{
        status: "order:updated",
        order: Publit.TransApi.OrderView.to_api(order)
      }
    }

    Publit.MessagingService.send_message_cli([token], msg, cb_ok, cb_err)
  end

  defp set_user_transport_cs(order, ut) do
    ut
    |> change()
    |> put_change(:orders, ut.orders ++ [%{"id" => order.id, "status" => "transporting" }])
    |> put_change(:extra_data, Map.put(ut.extra_data, "trans_status", "transport"))
  end

  defp log_error(resp) do
    IO.inspect(resp, label: "Log error")
  end

end
