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
    |> Map.drop([:__meta__, :__struct__, :organization])
    |> Map.put(:pos, Geo.JSON.encode(order.pos))
    |> Map.put(:user_client, Publit.UserView.to_api(order.user_client))
  end

  def encode_with_user(order) do
    order = order |> Repo.preload(:user_client)

    Map.drop(order, [:__struct__, :__meta__, :pos])
    |> Map.put(:pos, Geo.JSON.encode(order.pos))
  end
end
