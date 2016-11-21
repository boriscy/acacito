defmodule Publit.OrderTest do
  use Publit.ModelCase

  alias Publit.Order

  @valid_attrs %{details: %{}, location: "some content", total: "120.5", user_id: "7488a646-e31f-11e4-aace-600308960662"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Order.changeset(%Order{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Order.changeset(%Order{}, @invalid_attrs)
    refute changeset.valid?
  end
end
