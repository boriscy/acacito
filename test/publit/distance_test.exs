defmodule Publit.DistanceTest do
  use ExUnit.Case, async: false

  test "OK" do
    assert Publit.Distance.calculate_price("car") == 10.0
    assert Publit.Distance.calculate_price("walk") == 10.0
  end
end
