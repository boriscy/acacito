defmodule Publit.SearchService do
  import Ecto.Adapters.SQL
  alias Publit.{Repo}

  @base_sql """
  select o.id::text, o.name, o.location, o.tags, o.address, o.open, o.rating,
  o.rating_count, o.description, o.currency
  from organizations o, jsonb_array_elements(tags) as t
  where o.open = true and ST_Distance_Sphere(o.location, ST_MakePoint($1, $2)) <= $3 * 1000
  """

  def search(params) do
    {sql, params} = get_sql_and_params(params)

    case query(Repo, sql, params) do
      {:ok, res} -> map_results(res.rows)
    end
  end

  defp map_results(rows) do
    Enum.map(rows, fn(row) ->
      [id, name, location, tags, address, open, rating, rating_count, desc, curr] = row
      %{id: id, name: name, coords: Geo.JSON.encode(location),
        tags: tags, address: address, open: open, rating: rating, rating_count: rating_count,
        description: desc, currency: curr}
    end)
  end

  defp get_sql_and_params(params) do
    %{"coordinates" => [lng, lat], "radius" => rad} = params
    arr = [lng, lat, String.to_integer("#{rad}")]

    tags_m = case get_tags(params["tags"]) do
      {:ok, tags} -> %{sql: " and t->>'text' = any($tags)", args: tags, replace: "$tags"}
      _ -> %{sql: nil}
    end

    rating_m = if String.valid?(params["rating"]) && Regex.match?(~r/^[0-5]{1}$/, params["rating"]) do
      %{sql: " and o.rating >= $rating", args: String.to_integer(params["rating"]), replace: "$rating"}
    else
      %{sql: nil}
    end

    {sql, args} = map_sql_and_params([tags_m, rating_m])
    sql = @base_sql <> sql <> " group by o.id"

    {sql, arr ++ args}
  end

  defp get_tags(tags) do
    if is_list(tags) && Enum.count(tags) > 0 do
      {:ok, tags}
    else
      nil
    end
  end

  defp map_sql_and_params(params) do
    a = Enum.filter(params, fn(val) -> val.sql end)
    |> Enum.with_index
    |> Enum.map(fn({val, idx}) ->
      sql = String.replace(val.sql, val.replace, "$" <> to_string(idx + 4))
      {sql, val.args}
    end)

    sql = Enum.map(a, fn({sql, _args}) -> sql end) |> Enum.join(" ")
    args = Enum.map(a, fn({_sql, arg}) -> convert(arg) end)

    {sql || "", args}
  end

  defp convert(arg) do
    cond do
      is_number(arg) -> arg
      is_list(arg) -> arg
      true -> arg
    end
  end

end
