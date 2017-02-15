defmodule Publit.OrderCallService do
  use Publit.Web, :model
  import Ecto.Query
  alias Ecto.Multi

  alias Publit.{Order, OrderCall, OrderTransport, Repo}

  @moduledoc """
  This module handles the call and updates both Order and OrderCall as well as it sends
  notifications to all UserTransport that have received
  """

  def accept(order, ut, params) do
    case Repo.one(order_call_query(order)) do
      nil -> :empty
      oc ->
        multi = Multi.new()
        |> Multi.update(:order, update_order(order, ut, params))
        |> Multi.delete_all(:order_call, order_call_query(order, ["new", "delivered"]))

        case Repo.transaction(multi) do
          {:ok, res} ->
            {:ok, pid} = send_messages(oc)
            {:ok, res.order, pid}
          {:error, res} ->
            {:error, res.order}
        end
    end
  end

  #@doc """
  #Receives a %Order{} and %UserTransport{} to update the order
  #"""
  defp update_order(order, ut, %{final_price: fp}) do
    params = %{transport: %{id: order.transport.id, transporter_id: ut.id, final_price: fp, transporter_name: ut.full_name} }

    order
    |> cast(params, [])
    |> put_change(:status, "transport")
    |> put_change(:user_transport_id, ut.id)
    |> Order.add_log(%{type: "update_transport", message: "New transport", user_transport_id: ut.id, user_transport: ut.full_name, mobile_number: ut.mobile_number})
    |> cast_embed(:transport, [with: &OrderTransport.changeset_update/2 ])
  end

  defp order_call_query(order, statuses \\ ["delivered"]) do
    from oc in OrderCall, where: oc.order_id == ^order.id and oc.status in ^statuses
  end

  defp send_messages(oc) do
    uts = Repo.all(from ut in Publit.UserTransport, where: ut.id in ^oc.transport_ids)
    tokens = Enum.map(uts, fn(t) -> t.extra_data["fb_token"] end)

    cb_ok = fn(_) -> end
    cb_err = fn(resp) -> log_error(resp) end

    Publit.MessagingService.send_messages(tokens, %{order_id: oc.order_id,
      order_call_id: oc.id, status: "order:answered"}, cb_ok, cb_err)
  end

  defp log_error(resp) do
    IO.inspect(resp)
  end

end