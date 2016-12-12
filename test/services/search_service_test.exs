defmodule Publit.SearchServiceTest do
  use ExUnit.Case, async: true

  alias Publit.{SearchService}


  describe "search" do
    test "defaults" do
      SearchService.criteria(%{
        "location" => %{"coordinates" => [-18.1778,-63.8748], "type" => "Point"}
      })
    end
  end
end
