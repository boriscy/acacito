defmodule Publit.PosService do
  @moduledoc """
  Updates the position for transportation, depending if it's carrying orders
  will send messages to the client or organization
  """

  use Publit.Web, :model
  import Publit.Gettext

  alias Publit.{Repo, Order, OrderTransport}
  alias Ecto.Multi

  @earth_radius_km 6371
  @max_dist_mt 200

  def update_pos(user_t, params) do
    case Enum.count(user_t.orders) > 0 do
      true -> update_pos_and_message(user_t, params)
      false -> update_pos_only(user_t, params)
    end
  end

  defp update_pos_only(user_t, params) do
    user_t
    |> cast(params, [:pos])
    |> put_change(:status, "listen")
    |> validate_required([:pos])
    |> valid_position()
    |> Repo.update()
  end

  defp update_pos_and_message(user_t, params) do
    Enum.each(user_t.orders, fn(ord) ->
      if requires_messaging(ord, params["pos"]) do
        send_message(user_t, ord)
      end
    end)

    update_pos_only(user_t, params)
  end

  defp send_message(user_t, ord) do
    order = Repo.get(Order, ord["order_id"]) |> Repo.preload([:organization, :user_client])
    tokens = [order.user_client.extra_data["fb_token"]]

    case ord["status"] do
      "transport" ->
        case update_order_transport(order, user_t, "picked_arrived_at") do
          {:ok, res} ->
            Publit.OrganizationChannel.broadcast_order(res.order, "order:near_org")
        end
      "transporting" ->
        ok_cb = fn(_) ->
          update_order_transport(order, user_t, "delivered_arrived_at")
        end
        err_cb = fn(_) -> "" end

        {title, msg} = {gettext("Transport near"), gettext("Your order is arriving")}
        Publit.MessagingService.send_messages(tokens, %{title: title, message: msg, status: "order:near_client"}, ok_cb, err_cb)
        Publit.OrganizationChannel.broadcast_order(order, "order:near_client")
    end
  end

  defp requires_messaging(ord, params) do
    cond do
      ord["status"] == "transport" && !ord["picked_arrived_at"] ->
        is_near(ord["organization_pos"], params)
      ord["status"] == "transporting" && !ord["delivered_arrived_at"] ->
        is_near(ord["client_pos"], params)
      true ->
        false
    end
  end

  def is_near(p1, p2) do
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

  defp update_order_transport(order, user_t, param) do
    dt = DateTime.to_string(DateTime.utc_now())

    multi = Multi.new()
    |> Multi.update(:order, update_order(order, param, dt))
    |> Multi.update(:user_transport, update_transport(user_t, order.id, param, dt))

    Repo.transaction(multi)
  end

  defp update_transport(user_t, order_id, param, dt) do
    case Enum.find_index(user_t.orders, fn(o) -> o["order_id"] == order_id end) do
      nil -> :error
      idx ->
        orders = List.update_at(user_t.orders, idx, fn(o) ->
          Map.put(o, param, dt)
        end)

        change(user_t)
        |> put_change(:orders, orders)
    end
  end

  defp update_order(order, param, dt) do
    params = Map.put(%{"id" => order.transport.id}, param, dt)

    order
    |> cast(%{transport: params}, [])
    |> cast_embed(:transport, [with: fn(ot, p) -> OrderTransport.changeset_delivery(ot, p) end])
  end

end
