defmodule Publit.CartServiceTest do
  use Publit.ModelCase

  alias Publit.CartService

  #table = :ets.new(:buckets_registry, [:set, :protected])

  test "add, lookup and delete" do
    id = Ecto.UUID.generate
    res = CartService.insert(id, %{name: "amaru", alias: "enanito bonito"})

    assert res
    data = CartService.lookup(id)

    assert data == %{name: "amaru", alias: "enanito bonito"}

    CartService.delete(id)

    assert CartService.lookup(id) == nil
  end
end
