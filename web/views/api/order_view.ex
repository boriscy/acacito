defmodule Publit.Api.OrderView do
  use Publit.Web, :view
  alias Publit.{UserClient, Repo}
  #import Publit.ErrorHelpers, only: [get_errors: 1]

  def render("index.json", %{orders: orders}) do
    orders = Enum.map(orders, &to_api/1)

    %{orders: orders}
  end

  def render("show.json", %{order: order}) do
    %{order: to_api(order)}
  end

  def render("errors.json", %{cs: cs}) do
    err = Map.put(get_errors(cs), :transport_errors, get_errors(cs.changes.transport))
    %{errors: err}
  end

  def render("not_found.json", %{msg: msg}) do
    %{error: msg}
  end

  def to_api(order) do
    order = case order.user_client do
      %Ecto.Association.NotLoaded{} -> order |> Repo.preload(:user_client)
      %UserClient{} -> order
    end

    order
    |> Map.drop([:__meta__, :__struct__, :organization, :user_transport, :order_calls, :chat, :log])
    |> Map.put(:client_pos, Geo.JSON.encode(order.client_pos))
    |> Map.put(:organization_pos, Geo.JSON.encode(order.organization_pos))
    |> Map.put(:user_client, Publit.UserView.to_api(order.user_client))
    #|> Map.put(:order_calls, encode_order_calls(order) )
  end

  def encode_with_user(order) do
    order = order |> Repo.preload(:user_client)

    Map.drop(order, [:__struct__, :__meta__, :pos, :user_transport])
    |> Map.put(:client_pos, Geo.JSON.encode(order.client_pos))
    |> Map.put(:organization_pos, Geo.JSON.encode(order.organization_pos))
  end

  def to_api2(order) do
    order
    |> Map.drop([:__meta__, :__struct__, :organization, :user_transport, :log, :user_client, :user_transport, :chat, :order_calls])
    |> Map.put(:client_pos, Geo.JSON.encode(order.client_pos))
    |> Map.put(:organization_pos, Geo.JSON.encode(order.organization_pos))
    |> Map.put(:user_client, Publit.UserView.to_api(order.user_client))
  end

  defp encode_order_calls(order) do
    case is_list(order.order_calls) do
      true ->
        order.order_calls
        |> Enum.filter(fn(oc) -> oc.status == "new" || oc.status == "delivered" end)
        |> Enum.map(fn(oc) -> Map.drop(oc, [:__meta__, :__struct__, :order, :resp]) end)
      false -> []
    end
  end

end
