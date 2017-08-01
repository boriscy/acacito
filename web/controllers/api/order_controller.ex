defmodule Publit.Api.OrderController do
  use Publit.Web, :controller
  alias Publit.{Order, Repo, UserChannel, Order.StatusService}

  # GET /api/orders
  def index(conn, _params) do
    org_id = conn.assigns.current_organization.id
    orders = Order.Query.active(org_id) |> Repo.preload(:order_calls)

    render(conn, "index.json", orders: orders)
  end

  # GET /api/orders/:id
  def show(conn, %{"id" => id}) do
    case (get_order(conn, id)) do
      nil ->
        render_not_found(conn)
      order ->
        render(conn, "show.json", order: order)
    end
  end

  # Move order when going from new to process, required process_time
  # PUT /api/orders/:id/move_next
  def move_next(conn, %{"id" => id, "order" => order_params}) do
    with ord <- get_order(conn, id),
      %Order{} <- ord do
        user = conn.assigns.current_user

        case Order.StatusService.next_status(ord, user, order_params) do
          {:ok, order} ->
            render(conn, "show.json", order: order)
          _ ->
            render(conn, "error.json")
        end
    else
      _ ->
        render_not_found(conn)
    end
  end

  # PUT /api/orders/:id/move_next
  def move_next(conn, %{"id" => id}) do
    with ord <- get_order(conn, id),
      %Order{} <- ord do
        user = conn.assigns.current_user

        case Order.StatusService.next_status(ord, user) do
          {:ok, order} ->
            render(conn, "show.json", order: order)
          _ ->
            render(conn, "error.json")
        end
    else
      _ ->
        render_not_found(conn)
    end
  end

  # PUT /api/orders/:id/move_back
  def move_back(conn, %{"id" => id}) do
    with ord <- get_order(conn, id),
      %Order{} <- ord do
        user = conn.assigns.current_user

        case Order.StatusService.previous_status(ord, user) do
          {:ok, order} ->
            render(conn, "show.json", order: order)
          _ ->
            render(conn, "error.json")
        end
    else
      _ ->
        render_not_found(conn)
    end
  end

  # PUT /api/orders/:id/null
  def null(conn, %{"id" => id, "order" => order_params}) do
    with ord <- get_order(conn, id),
      %Order{} <- ord do
        user = conn.assigns.current_user

        case Order.Null.null(ord, user, order_params) do
          {:ok, order} ->
            render(conn, "show.json", order: order)
          {:error, :order, cs} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render("null_errors.json", cs: cs)
        end
    else
      _ ->
        render_not_found(conn)
    end
  end

  defp render_not_found(conn, args \\ %{msg: gettext("Could not find the order")}) do
    conn
    |> put_status(:not_found)
    |> render("not_found.json", msg: args.msg)
  end

  defp get_order(conn, id) do
    org_id = conn.assigns.current_organization.id

    Repo.get_by(Order, id: id, organization_id: org_id) |> Repo.preload(:user_client)
  end
end
