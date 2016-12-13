defmodule Publit.SearchService do
  import Ecto.Adapters.SQL
  import Ecto.Query
  alias Publit.{Repo}

  @base_sql """
  select o.id::text, o.name, o.geom, o.tags, o.address, o.open
  from organizations o, jsonb_array_elements(tags) as t
  where o.open = true and ST_Distance_Sphere(o.geom, ST_MakePoint($1, $2)) <= $3 * 1000
  """

  def search(params) do
    {sql, params} = get_sql_and_params(params)

    case query(Repo, sql, params) do
      {:ok, res} -> map_results(res.rows)
    end
  end

  defp map_results(rows) do
    Enum.map(rows, fn(row) ->
      [id, name, geom, tags, address, open] = row
      %{id: id, name: name, coors: Geo.JSON.encode(geom),
        tags: tags, address: address, open: open}
    end)
  end

  defp get_sql_and_params(params) do
    %{"coordinates" => [lng, lat], "radius" => rad} = params
    arr = [lng, lat, String.to_integer(rad)]

    tags_m = case get_tags(params["tags"]) do
      {:ok, tags} -> %{sql: " and t->>'text' in($tags)", args: tags, replace: "$tags"}
      _ -> %{sql: nil}
    end

    rating_m = if String.valid?(params["rating"]) && Regex.match(~r/^\d$/, params["rating"]) do
      %{sql: " and o.rating >= $rating", args: String.to_integer(params["rating"]), replace: "$rating"}
    else
      %{sql: nil}
    end

    {sql, args} = map_sql_and_params([tags_m, rating_m])
    sql = @base_sql <> sql <> " group by o.id"

    IO.inspect sql
    IO.inspect arr ++ args
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

    sql = Enum.map(a, fn({sql, args}) -> sql end) |> Enum.join(" ")
    args = Enum.map(a, fn({sql, arg}) -> convert(arg) end)

    {sql || "", args}
  end

  defp convert(arg) do
    cond do
      is_number(arg) -> to_string(arg)
      is_list(arg) -> Enum.map(arg, &(to_string(&1))) |> Enum.join(", ")
      true -> arg
    end
  end

end
