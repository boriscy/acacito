defmodule Publit.ClientApi.OrderView do
  use Publit.Web, :view
  alias Publit.{Organization, Repo}

  def render("index.json", %{orders: orders}) do
    orders = Enum.map(orders, &to_api/1)

    %{orders: orders}
  end

  def render("show.json", %{order: order}) do
    %{order: to_api(order)}
  end

  def render("errors.json", %{cs: cs}) do
    #err = Map.put(get_errors(cs), :transport_errors, get_errors(cs.changes.transport))
    %{errors: get_errors(cs)}
  end

  def render("not_found.json", %{msg: msg}) do
    %{error: msg}
  end

  def to_api(order) do
    order = case order.organization do
      %Ecto.Association.NotLoaded{} -> order |> Repo.preload(:organization)
      %Organization{} -> order
    end

    order
    |> Map.drop([:__meta__, :__struct__, :user_client, :user_transport, :chat, :log,:order_calls])
    |> Map.put(:client_pos, Geo.JSON.encode(order.client_pos))
    |> Map.put(:organization_pos, Geo.JSON.encode(order.organization_pos))
    |> Map.put(:organization, Publit.OrganizationView.to_api(order.organization))
  end

end
