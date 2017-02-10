defmodule Publit.Api.TransportController do
  use Publit.Web, :controller
  alias Publit.{OrderCall, Order}

  # POST /api/transport
  # Creates a call to transports
  def create(conn, %{"order_id" => order_id}) do
    org = conn.assigns[:current_organization]
    order = Repo.get_by(Order, id: order_id, organization_id: org.id)

    if is_nil(order) do
      conn
      |> put_status(:not_found)
      |> render("not_found.json")
    else
      case OrderCall.create(order, 1_000) do
        {:ok, oc, _pid} ->
          render(conn, "show.json", order_call: oc)
        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render("errors.json", cs: cs)
        {:empty, oc} ->
          conn
          |> put_status(:failed_dependency)
          |> render("show.json", order_call: oc)
      end
    end
  end

end
