defmodule Publit.SearchService do
  def search(params) do

  end

  @doc """
  Creates a criteria for searching, setting default params when neccesary
  """
  def criteria(params) do
    [lng, lat] = params["location"]["coordinates"]
  end
end
