defmodule Publit.ClientApi.CommentView do
  use Publit.Web, :view

  def render("show.json", %{comment: comment, order: order}) do
    %{comment: to_api(comment), order: Publit.OrderView.to_api(order)}
  end

  def render("show.json", %{comment: comment}) do
    %{comment: to_api(comment)}
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end

  def render("errors.json", %{cs: cs}) do
    %{errors: get_errors(cs)}
  end

  def render("comments.json", %{comments: comments}) do
    %{comments: Enum.map(comments, fn(c) -> to_api(c) end)}
  end

  def to_api(comment) do
    comment |> Map.drop([:__meta__, :__struct__, :order])
  end
end
