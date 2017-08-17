defmodule Publit.PosService do
  @moduledoc """
  Updates the position for transportation, depending if it's carrying orders
  will send message to the client or organization
  """

  use Publit.Web, :model
  import Ecto.Query
  import Publit.Gettext

  alias Publit.{Repo, Order, Order.Transport}
  alias Ecto.Multi

  @earth_radius_km 6371
  @max_dist_mt 100

  def update_pos(user_t, params) do
    case Enum.count(user_t.orders) > 0 do
      true -> update_orders_and_user_transport(user_t, params)
      false -> update_user_transport_pos(user_t, params)
    end
  end

  defp update_user_transport_pos(user_t, params) do
    user_t
    |> cast(params, [:pos])
    |> put_change(:status, "listen")
    |> validate_required([:pos])
    |> valid_position()
    |> Repo.update()
  end

  defp update_orders_and_user_transport(user_t, params) do
    orders = get_orders(user_t.orders |> Enum.map(fn(ord) -> ord["id"] end) )
    msg = %{"type" => "trans", "pos" => params["pos"]}

    multi = Enum.reduce(orders, Multi.new(), fn(order, m) ->
      if requires_messaging?(order, params["pos"]) do
        send_message(order, user_t)

        msg = Map.merge(msg, %{"send_msg" => true, "status" => order.status})
        Multi.update(m, order.id, set_order_changeset(order, true, params["pos"]))
      else
        Multi.update(m, order.id, set_order_changeset(order, false, params["pos"]))
      end
      |> Multi.run(:log, fn(_) -> Order.Log.add(order.id, msg) end)
    end)
    |> Multi.update(:transport, set_transport_orders_and_pos(user_t, orders, params["pos"]))

    case Repo.transaction(multi) do
      {:ok, res} ->
        {:ok, res.transport}
      {:error, res} -> {:error, res}
    end
  end

  defp get_orders(order_ids) do
    order_ids = Enum.reduce(order_ids, [], fn(id, l) ->
      case Ecto.UUID.cast(id) do
        {:ok, _id} -> l ++ [id]
        _ -> l
      end
    end)

    (from o in Order, where: o.id in ^order_ids and o.status in ^["transport", "transporting"])
    |> Repo.all()
    |> Repo.preload(:user_client)
  end

  defp set_order_changeset(order, messaging, pos) do
    t_data = case {order.status, messaging} do
      {"transport", true} ->
        %{picked_arrived_at: to_string(DateTime.utc_now())}
      {"transporting", true} ->
        %{delivered_arrived_at: to_string(DateTime.utc_now())}
      _ ->
        %{}
    end

    cs = change(order)
    |> put_embed(:trans, Map.merge(order.trans, t_data))
  end

  # sends the actual message
  defp send_message(order, _user_t) do
    tokens = [order.user_client.extra_data["device_token"]]

    case order.status do
      "transport" ->
         Publit.OrganizationChannel.broadcast_order(order, "order:near_org")
      "transporting" ->
        ok_cb = fn(_) -> "" end
        err_cb = fn(_) -> "" end

        {title, msg} = {gettext("Transport near"), gettext("Your order is arriving")}
        Publit.OrganizationChannel.broadcast_order(order, "order:near_client")
        Publit.MessagingService.send_message_cli(tokens, %{title: title, message: msg, status: "order:near_client"}, ok_cb, err_cb)
    end
  end

  defp requires_messaging?(order, pos) do
    cond do
      order.status == "transport" && !order.trans.picked_arrived_at ->
        near?(Geo.JSON.encode(order.organization_pos), pos)
      order.status == "transporting" && !order.trans.delivered_arrived_at ->
        near?(Geo.JSON.encode(order.client_pos), pos)
      true ->
        false
    end
  end

  def near?(p1, p2) do
    calculate_distance_in_mt(p1, p2) <= @max_dist_mt
  end

  defp valid_position(cs) do
    with {:pos, true} <- {:pos, !!cs.changes[:pos]},
      %Geo.Point{coordinates: {lng, lat}} <- cs.changes.pos,
      {:num, true} <- {:num, (is_number(lng) && is_number(lat) )},
      {:range, true} <- {:range, (lng >= -180 && lng <= 180 && lat >= -90 && lat <= 90)}
       do
        cs
    else
      _ ->
        add_error(cs, :pos, "Invalid position")
    end
  end

  def calculate_distance_in_km(p1, p2) do
    [lng1, lat1] = p1["coordinates"]
    [lng2, lat2] = p2["coordinates"]

    d_lat = deg_to_rad(lat2 - lat1)
    d_lng = deg_to_rad(lng2 - lng1)

    a = :math.sin(d_lat / 2) * :math.sin(d_lat / 2) +
      :math.cos(deg_to_rad(lat1)) * :math.cos(deg_to_rad(lat2)) *
      :math.sin(d_lng / 2) * :math.sin(d_lng / 2)

    c = 2 * :math.atan2(:math.sqrt(a), :math.sqrt(1 - a))

    @earth_radius_km * c
  end

  def calculate_distance_in_mt(p1, p2) do
    calculate_distance_in_km(p1, p2) * 1000
  end

  def deg_to_rad(deg) do
    deg * :math.pi / 180
  end

  defp set_transport_orders_and_pos(user_t, orders, pos) do
    change(user_t)
    |> cast(%{pos: pos}, [:pos])
    |> put_change(:orders, Enum.map(orders, &set_order_transport/1))
  end

  defp set_order_transport(order) do
    Map.take(order, [:id, :status])
    |> Enum.into(%{}, fn({k, v}) -> {to_string(k), v} end)
  end

end
