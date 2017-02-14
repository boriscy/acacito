defmodule Publit.OrderCallService do
  use Publit.Web, :model
  import Ecto.Query

  alias Publit.{Order, OrderCall}

  @moduledoc """
  This module handles the call and updates both Order and OrderCall as well as it sends
  notifications to all UserTransport that have received
  """

  def accept(order, ut, params) do
    case Repo.one(order_call_query(order))
      %OrderCall{transport_ids: transport_ids} ->
        multi = Multi.new()
        |> Multi.update(:order, update_order)
        |> Multi.delete(:order_calls, oc)

        case Repo.transaction(multi) do
          {:ok, res} ->
            send_messages(transport_ids)
            {:ok, res.order}
          {:error, res} ->
            {:error, res.order}
        end
      nil ->
        :empty
    end
  end

  @doc """
  Receives a %Order{} and %UserTransport{} to update the order
  """
  defp update_order(order, ut, %{final_price: fp}) do
    params = %{transport: %{id: order.transport.id, transporter_id: ut.id, final_price: fp, transporter_name: ut.full_name} }

    order
    |> cast(params, [])
    |> put_change(:status, "transport")
    |> put_change(:user_transport_id, ut.id)
    |> add_log(%{type: "update_transport", message: "New transport", user_transport_id: ut.id, user_transport: ut.full_name, mobile_number: ut.mobile_number})
    |> cast_embed(:transport, [with: &OrderTransport.changeset_update/2 ])
  end

  def get_order_call() do
    Repo.one(order_call_query(order))
  end

  defp order_call_query(order, statuses \\ ["delivered"]) do
    from oc in OrderCall, where: oc.order_id == ^order.id and oc.status == ^statuses
  end

  defp send_messages(transport_ids) do

  end

end
