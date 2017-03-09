defmodule Publit.Array do
  @behaviour Ecto.Type
  def type, do: :array

  # Provide our own casting rules.
  def cast(array) when is_map(array) do
    array = array |> Enum.into([], fn({_key, val}) -> val end)
    {:ok, array}
  end

  # Cast when it's a list
  def cast(array) when is_list(array), do: {:ok, array}

  # Everything else is a failure though
  def cast(_), do: :error

  # When loading data from the database, we are guaranteed to
  # return a list
  def load(array) when is_list(array), do: {:ok, array}

  # When dumping data to the database, we *expect* an integer
  # but any value could be inserted into the struct, so we need
  # guard against them.
  def dump(array) when is_list(array), do: {:ok, array}
  def dump(_), do: :error
end
