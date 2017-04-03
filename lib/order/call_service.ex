defmodule Publit.Order.CallService do
  use Publit.Web, :model
  import Ecto.Query
  import Publit.Gettext
  alias Ecto.Multi

  alias Publit.{Order, Order.Call, Order.Transport, Repo}

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
            {:ok, pid} = send_message(oc, ut, order)
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
    params = %{transport: %{id: order.transport.id, transporter_id: ut.id, final_price: fp, transporter_name: ut.full_name,
               vehicle: ut.vehicle, plate: ut.plate} }

    order
    |> cast(params, [])
    |> put_change(:status, "transport")
    |> put_change(:user_transport_id, ut.id)
    |> cast_embed(:transport, [with: &Order.Transport.changeset_update/2])
  end

  defp order_call_query(order, statuses \\ ["delivered"]) do
    from oc in Order.Call, where: oc.order_id == ^order.id and oc.status in ^statuses
  end

  defp send_message(oc, ut, order) do
    uts = Repo.all(from ut in Publit.UserTransport, where: ut.id in ^oc.transport_ids)
    tokens = Enum.map(uts, fn(t) -> t.extra_data[@token_id] end)

    cb_ok = fn(_) -> "" end
    cb_err = fn(resp) -> log_error(resp) end

    msg = %{
      message: gettext("New order from %{org}", org: order.organization_name),
      data: %{
        order_call_id: oc.id,
        order: Publit.TransApi.OrderView.to_api(order)
      }
    }

    Publit.MessagingService.send_message(tokens, msg, cb_ok, cb_err)
  end

  defp set_user_transport_cs(order, ut) do
    ut
    |> change()
    |> put_change(:orders, ut.orders ++ [%{"id" => order.id, "status" => "transporting" }])
  end

  defp log_error(resp) do
    IO.inspect(resp)
  end

end
