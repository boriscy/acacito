defmodule Publit.ProductView do
  use Publit.Web, :view

  def img_url(version, product) do
    Publit.ProductImage.img_url(version, product)
  end

  def encode_variations(cs) do
    data = if cs.changes == %{} do
      variations_data(:data, cs.data.variations)
    else
      cs.changes.variations
      variations_data(:changes, cs.changes.variations)
    end

    Poison.encode!(data)
  end

  defp variations_data(:data, variations) do
    Enum.map(variations, fn(p) -> %{name: p.name, price: p.price} end)
  end

  defp variations_data(:changes, variations) do
    Enum.map(variations, fn(p) ->
      %{name: p.changes[:name], price: p.changes[:price], errors: get_errors(p)}
    end)
  end

  defp get_errors(p) do
    Enum.map(p.errors, fn({k, v}) ->
      msg = translate_error({elem(v, 0), elem(v, 1)})
      {k, msg}
    end) |> Enum.into(%{})
  end
end
