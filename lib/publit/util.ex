defmodule Publit.Util do
  def map_to_list(map) when is_map(map) do
    Enum.to_list(map)
    |> Enum.map(fn({_, v}) -> v end)
  end
  def map_to_list(map) when is_list(map), do: map

  def map_to_list(map, :atom) do
    map_to_list(map)
    |> Enum.map(fn(val) ->
      case Map.keys(val) |> List.first |> is_binary do
        true ->
          for {key, val} <- val, into: %{}, do: {String.to_atom(key), val}
        false -> val
      end
    end)
  end

  def atomize_keys(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end
end
