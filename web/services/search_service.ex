defmodule Publit.SearchService do
  import Ecto.Adapters.SQL
  alias Publit.{Repo}

  @base_sql """
  SELECT o.id::text, o.name, o.pos, o.tags, o.address, o.open, o.rating,
  o.rating_count, o.description, o.currency
  FROM organizations o, JSONB_ARRAY_ELEMENTS(tags) as t
  WHERE o.open = true AND ST_Distance_Sphere(o.pos, ST_MakePoint($1, $2)) <= $3 * 1000
  """

  def search(params) do
    {sql, params} = get_sql_and_params(params)
    case query(Repo, sql, params) do
      {:ok, res} -> map_results(res.rows)
    end
  end

  defp map_results(rows) do
    Enum.map(rows, fn(row) ->
      [id, name, pos, tags, address, open, rating, rating_count, desc, curr] = row
      %{id: id, name: name, pos: Geo.JSON.encode(pos),
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

    rating_m = case get_rating(params["rating"]) do
      nil ->
        %{sql: nil}
      rating ->
        %{sql: " and round(o.rating) >= $rating", args: rating, replace: "$rating"}
    end

    {sql, args} = map_sql_and_params([tags_m, rating_m])
    sql = @base_sql <> sql <> " group by o.id"

    {sql, arr ++ args}
  end

  defp get_rating(rating) do
    cond do
      is_integer(rating) ->
        rating
      String.valid?(rating) && Regex.match?(~r/^[0-5]{1}$/, rating) ->
        String.to_integer(rating)
      true ->
        nil
    end
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
