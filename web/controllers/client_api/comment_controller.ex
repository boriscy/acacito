defmodule Publit.ClientApi.CommentController do
  use Publit.Web, :controller
  plug :scrub_params, "comment" when action in [:create]
  alias Publit.{Order}


  # GET /client_api/orders
  #def index(conn, _params) do
  #  user_id = conn.assigns.current_user_client.id

  #  render(conn, "index.json", orders: Order.Query.user_orders(user_id))
  #end

  # GET /client_api/orders/:id
  #def show(conn, %{"id" => id}) do
  #  case (Repo.get(Order, id) |> Repo.preload(:organization)) do
  #    nil ->
  #      render_not_found(conn)
  #    order ->
  #      render(conn, "show.json", order: order)
  #  end
  #end

  # POST /client_api/comment/:order_id
  def create(conn, %{"comment" => comment_params}) do
    uc = conn.assigns.current_user_client

    case Repo.get(Order, comment_params["order_id"]) do
      nil ->
        render_not_found(conn)
      order ->
        case Order.Comment.create(order, uc, comment_params) do
          {:ok, res} ->
            render(conn, "show.json", comment: res.comment, order: res.order)
          {:error, err} ->
            IO.inspect err
        end
    end
  end

  # PUT /client_api/comment/:id

  defp render_not_found(conn, args \\ %{msg: gettext("Could not find the order")}) do
    conn
    |> put_status(:not_found)
    |> render("not_found.json", msg: args.msg)
  end

end

