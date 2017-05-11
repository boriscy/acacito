defmodule Publit.CartTest do
  use Publit.ModelCase
  alias Publit.Cart

  test "with pid" do
    org = insert(:organization)
    prods = create_products(org)

    {:ok, pid} = Cart.start_link(org.id)

    %{id: id, items: items, ref: ref, organization_id: org_id} = Cart.get(pid)
    assert {:ok, _id} = Ecto.UUID.cast(id)
    assert {:ok, _id} = Ecto.UUID.cast(org_id)
    assert items == items
    assert is_reference(ref)

    prod = prods |> List.first()
    vari = prod.variations |> List.first()

    {p, va, q} = Cart.add_item(pid, prod.id, vari.id)
    assert p.id == prod.id
    assert va == vari
    assert q == 1

    Cart.add_item(pid, prod.id, vari.id, 3)
    res = Cart.get(pid)

    assert res.items |> Enum.count() == 1
    item = List.first(res.items)

    assert item.quantity == 3
    assert item.product.id == prod.id
    assert item.variation == vari

    prod2 = prods |> Enum.at(1)
    vari2 = prod2.variations |> Enum.at(1)

    Cart.add_item(pid, prod2.id, vari2.id, 2)

    res = Cart.get(pid)
    assert res.items |> Enum.count() == 2

    vari3 = prod2.variations |> Enum.at(0)
    Cart.add_item(pid, prod2.id, vari3.id, 5)

    res = Cart.get(pid)
    assert res.items |> Enum.count() == 3

    assert %{quantity: 3} = Enum.find(res.items, &(&1.variation == vari))
    assert %{quantity: 2} = Enum.find(res.items, &(&1.variation == vari2))
    assert %{quantity: 5} = Enum.find(res.items, &(&1.variation == vari3))
  end

  test "with uuid" do
    org = insert(:organization)
    prods = create_products(org)

    {:ok, pid} = Cart.start_link(org.id)

    %{id: id, items: items, ref: ref, organization_id: org_id} = Cart.get(pid)
    assert {:ok, _id} = Ecto.UUID.cast(id)
    assert {:ok, _id} = Ecto.UUID.cast(org_id)
    assert items == items
    assert is_reference(ref)

    prod = prods |> List.first()
    vari = prod.variations |> List.first()

    {p, va, q} = Cart.add_item(id, prod.id, vari.id)
    assert p.id == prod.id
    assert va == vari
    assert q == 1

    Cart.add_item(id, prod.id, vari.id, 7)
    res = Cart.get(id)

    assert res.items |> Enum.count() == 1
    item = List.first(res.items)

    assert item.quantity == 7
    assert item.product.id == prod.id
    assert item.variation == vari

    prod2 = prods |> Enum.at(1)
    vari2 = prod2.variations |> Enum.at(1)

    Cart.add_item(id, prod2.id, vari2.id, 2)

    res = Cart.get(id)
    assert res.items |> Enum.count() == 2

    vari3 = prod2.variations |> Enum.at(0)
    Cart.add_item(id, prod2.id, vari3.id, 5)

    res = Cart.get(id)
    assert res.items |> Enum.count() == 3

    assert %{quantity: 7} = Enum.find(res.items, &(&1.variation == vari))
    assert %{quantity: 2} = Enum.find(res.items, &(&1.variation == vari2))
    assert %{quantity: 5} = Enum.find(res.items, &(&1.variation == vari3))
  end
end
