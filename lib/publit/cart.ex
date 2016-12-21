defmodule Publit.Cart do
  use GenServer
  defstruct [:variation, :product, :quantity]
  alias Publit.{Repo, Product, CartService, Cart}

  def start_link(org_id, expires_in \\ 1000 * 60 * 30) do
    GenServer.start_link(__MODULE__, [organization_id: org_id, expires_in: expires_in])
  end

  def init(args) do
    ref = Process.send_after(self, :bye, args[:expires_in])
    id = Ecto.UUID.generate()

    CartService.insert(id, self)

    {:ok, %{id: id, ref: ref, items: [], organization_id: args[:organization_id]}}
  end

  def get(id)  when is_binary(id) do
    case CartService.lookup(id) do
      nil -> nil
      pid -> get(pid)
    end
  end
  def get(pid) do
    GenServer.call(pid, :get)
  end

  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end


  def add_item(id, product_id, variation_id, quantity) when is_binary(id) do
    case CartService.lookup(id) do
      nil -> {:error, :ivalid_cart}
      pid -> add_item(pid, product_id, variation_id, quantity)
    end
  end
  def add_item(pid, product_id, variation_id, quantity \\ 1) do
    if is_integer(quantity) && quantity > 0 do
      GenServer.call(pid, {:add_item, product_id, variation_id, quantity})
    else
      {:error, :invalid_quantity}
    end
  end

  def handle_call({:add_item, product_id, variation_id, quantity}, _from, state) do
    case Cart.get_product(state, product_id, variation_id) do
      {product, variation} ->
        state = Cart.update_state(state, product, variation, quantity)

        {:reply, {product, variation, quantity}, state}
      _ ->
        {:reply, {:error, :product_not_found}}
    end
  end

  def get_product(state, product_id, variation_id) do
    case Enum.find(state.items, &(&1.variation.id == variation_id)) do
      nil ->
        case find_product(state.organization_id, product_id, variation_id) do
          {product, variation} -> {product, variation}
          nil -> nil
        end
      item ->
        {item.product, item.variation}
    end

  end

  defp find_product(organization_id, product_id, variation_id) do
    with product <- Product.get(organization_id, product_id),
      false <- is_nil(product),
      variation <- Enum.find(product.variations, fn(v) -> v.id == variation_id end),
      false <- is_nil(variation) do
        {product, variation}
    else
      _ -> nil
    end
  end

  def update_state(state, product, variation, quantity) do
    case Enum.find(state.items, fn(v) -> v.variation && v.variation.id == variation.id end) do
      nil ->
        item  = %Cart{product: product, variation: variation, quantity: quantity}
        Map.put(state, :items, state.items ++ [item])
      item ->
        idx = Enum.find_index(state.items, &(&1.variation == item.variation))
        items = List.update_at(state.items, idx, fn(_) -> Map.put(item, :quantity, quantity) end)
        Map.put(state, :items, items)
    end
  end

  def handle_info(:bye, state) do
    {:stop, :shutdown, state}
  end
end
