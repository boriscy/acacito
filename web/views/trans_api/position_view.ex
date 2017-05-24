defmodule Publit.TransApi.PositionView do
  use Publit.Web, :view

  def render("position.json", %{user: user}) do
    %{user: encode_user_pos(user)}
  end

  def render("order.json", %{user: user, order: order}) do
    %{user: user, order: order}
  end

  def render("errors.json", %{cs: cs}) do
    %{errors: get_errors(cs)}
  end

  def encode_user_pos(user) do
    %{id: user.id, mobile_number: user.mobile_number, email: user.email, status: user.status,
      pos: Geo.JSON.encode(user.pos)}
  end
end
