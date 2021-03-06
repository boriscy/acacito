defmodule PublitWeb.Api.OrderView do
  use PublitWeb, :view
  alias Publit.{Repo}

  def render("index.json", %{orders: orders}) do
    %{orders: Enum.map(orders, &to_api/1)}
  end

  def render("show.json", %{order: order}) do
    %{order: to_api(order)}
  end

  def render("errors.json", %{cs: cs}) do
    err = Map.put(get_errors(cs), :transport_errors, get_errors(cs.changes.transport))
    %{errors: err}
  end

  def render("null_errors.json", %{cs: cs}) do
    %{errors: get_errors(cs)}
  end

  def render("not_found.json", %{msg: msg}) do
    %{error: msg}
  end

  def to_api(order) do
    PublitWeb.OrderView.to_api(order)
  end

  def encode_with_user(order) do
    order = order |> Repo.preload(:user_client)

    Map.drop(order, [:__struct__, :__meta__, :pos, :user_transport])
    |> Map.put(:client_pos, Geo.JSON.encode(order.client_pos))
    |> Map.put(:organization_pos, Geo.JSON.encode(order.organization_pos))
  end

  # TODO remove function
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
