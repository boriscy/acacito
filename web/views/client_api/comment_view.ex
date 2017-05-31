defmodule Publit.ClientApi.CommentView do
  use Publit.Web, :view

  def render("show.json", %{comment: comment, order: order}) do
    %{comment: to_api(comment), order: Publit.OrderView.to_api(order)}
  end

  def to_api(comment) do
    comment |> Map.drop([:__meta__, :__struct__, :order])
  end
end
