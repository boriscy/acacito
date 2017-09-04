defmodule Publit.CartService do
  use GenServer
  defstruct [:product, :variation, :quantity]


  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    name = :ets.new(:cart, [:named_table, read_concurrency: true])

    {:ok, name}
  end

  def insert(key, value) do
    GenServer.call(__MODULE__, {:insert, key, value})
  end

  def handle_call({:insert, key, value}, _from, name) do
    res = :ets.insert(name, {key, value})

    {:reply, res, name}
  end

  def lookup(key) do
    GenServer.call(__MODULE__, {:lookup, key})
  end

  def handle_call({:lookup, key}, _from, name) do
    res = case :ets.lookup(name, key) do
      [{_key, value}] -> value
      _ -> nil
    end

    {:reply, res, name}
  end

  def delete(key) do
    GenServer.call(__MODULE__, {:delete, key})
  end

  def handle_call({:delete, key}, _from, name) do
    res = :ets.delete(name, key)

    {:reply, res, name}
  end

end
