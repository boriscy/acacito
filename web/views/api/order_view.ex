defmodule Publit.Api.OrderView do
  use Publit.Web, :view
  alias Publit.{User, Organization, Repo}
  #import Publit.ErrorHelpers, only: [get_errors: 1]

  def render("index.json", %{orders: orders}) do
    orders = Enum.map(orders, fn(o) ->
      Map.put(o, :location, Geo.JSON.encode(o.location))
    end)
    %{orders: orders}
  end

  def render("show.json", %{order: order}) do
    %{order: to_api(order)}
  end

  def render("orders.json", %{orders: orders}) do
    orders = Enum.map(orders, &to_api/1)

    %{orders: orders}
  end

  def render("errors.json", %{cs: cs}) do
    err = Map.put(get_errors(cs), :transport_errors, get_errors(cs.changes.transport))
    %{errors: err}
  end

  def render("not_found.json", %{msg: msg}) do
    %{error: msg}
  end

  def to_api(order) do
    order
    |> Map.drop([:__meta__, :__struct__])
    |> Map.put(:location, Geo.JSON.encode(order.location))
    |> Map.put(:organization, Publit.OrganizationView.to_api(order.organization))
  end

  def encode_with_user(order) do
    user = Repo.get(User, order.user_id)

    Map.drop(order, [:__struct__, :__meta__, :location])
    |> Map.put(:location, Geo.JSON.encode(order.location))
    |> Map.put(:client, user.full_name || user.email)
  end
end
