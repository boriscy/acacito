defmodule Publit.Api.OrderView do
  use Publit.Web, :view
  alias Publit.{User, Repo}
  #import Publit.ErrorHelpers, only: [get_errors: 1]

  def render("index.json", %{orders: orders}) do
    orders = Enum.map(orders, fn(o) ->
      Map.put(o, :location, Geo.JSON.encode(o.location))
    end)
    %{orders: orders}
  end

  def render("show.json", %{order: order}) do
    %{order: order}
  end

  def render("errors.json", %{cs: cs}) do
    %{errors: get_errors(cs)}
  end

  def encode_with_user(order) do
    user = Repo.get(User, order.user_id)

    ord = Map.drop(order, [:__struct__, :__meta__, :location])
    |> Map.put(:location, Geo.JSON.encode(order.location))
    |> Map.put(:client, user.full_name || user.email)
  end
end
