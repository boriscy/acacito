defmodule PublitWeb.ClientApi.CommentController do
  use PublitWeb, :controller
  plug :scrub_params, "comment" when action in [:create]
  alias Publit.{Order}

  # GET /client_api/orders/:id
  def comments(conn, %{"order_id" => order_id}) do
    q = from c in Order.Comment, where: c.order_id == ^order_id and c.comment_type in ^["cli_org", "cli_trans"]

    render(conn, "comments.json", comments: Repo.all(q))
  end

  # POST /client_api/comment/:order_id
  def create(conn, %{"comment" => comment_params}) do
    uc = conn.assigns.current_user_client

    case Repo.get(Order, comment_params["order_id"]) do
      nil ->
        render_order_not_found(conn)
      order ->
        case Order.Comment.create(order, uc, comment_params) do
          {:ok, res} ->
            render(conn, "show.json", comment: res.comment, order: res.order)
          {:error, err} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render("error.json", error: err)
        end
    end
  end

  # PUT /client_api/comment/:id
  def update(conn, %{"id" => id, "comment" => comment_params}) do
    case Repo.get(Order.Comment, id) do
      nil ->
        render_comment_not_found(conn)
      comment ->
        case Order.Comment.update(comment, comment_params) do
          {:ok, res} ->
            render(conn, "show.json", comment: res.comment, order: res.order)
          {:error, err} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render("errors.json", cs: err)
        end
    end
  end

  defp render_order_not_found(conn, args \\ %{msg: gettext("Could not find the order")}) do
    conn
    |> put_status(:not_found)
    |> render(PublitWeb.TransApi.OrderView, "not_found.json")
  end

  defp render_comment_not_found(conn) do
    conn
    |> put_status(:not_found)
    |> text(gettext("Comment not found"))
  end
end
