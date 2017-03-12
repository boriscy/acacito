defmodule Publit.ClientApi.OrderController do
  use Publit.Web, :controller
  plug :scrub_params, "order" when action in [:create]
  alias Publit.{Order}


  # GET /client_api/orders
  def index(conn, _params) do
    user_id = conn.assigns.current_user_client.id

    render(conn, "index.json", orders: Order.Query.user_active_orders(user_id))
  end

  # GET /api/orders/:id
  def show(conn, %{"id" => id}) do
    case (Repo.get(Order, id) |> Repo.preload(:organization)) do
      nil ->
        render_not_found(conn)
      order ->
        render(conn, "show.json", order: order)
    end
  end

  # POST /client_api/orders
  def create(conn, %{"order" => order_params}) do
    order_params = get_params(conn, order_params)

    case Order.create(order_params) do
      {:ok, order} ->
        Publit.OrganizationChannel.broadcast_order(order)
        render(conn, "show.json", order: order)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

  defp render_not_found(conn, args \\ %{msg: gettext("Could not find the order")}) do
    conn
    |> put_status(:not_found)
    |> render("not_found.json", msg: args.msg)
  end

  defp get_params(conn, order_params) do
    uc = conn.assigns.current_user_client
    order_params
    |> Map.put("user_client_id", uc.id)
    |> Map.put("client_name", uc.full_name)
  end

end
