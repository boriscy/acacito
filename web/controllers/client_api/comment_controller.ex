defmodule Publit.ClientApi.CommentController do
  use Publit.Web, :controller
  plug :scrub_params, "comment" when action in [:create]
  alias Publit.{Order}

  # GET /client_api/orders/:id
  def show(conn, %{"id" => id}) do
    case Repo.get(Comment, id) do
      nil ->
        render_not_found(conn)
      comment ->
        render(conn, "show.json", comment: comment)
    end
  end

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
            conn
            |> put_status(:unprocessable_entity)
            |> render("error.json", error: err)
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

