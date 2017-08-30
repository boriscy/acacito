defmodule Publit.UtilTest do
  use ExUnit.Case

  @m %{"0" => %{"address" => "Los Pinos B100"}, "1" => %{"address" => "Jejeje"}}

  describe "map_to_ist" do
    test "map with binary" do
      assert Publit.Util.map_to_list(@m) == [%{"address" => "Los Pinos B100"}, %{"address" => "Jejeje"}]
    end

    test "map with atom" do
      assert Publit.Util.map_to_list(@m, :atom) == [%{address: "Los Pinos B100"}, %{address: "Jejeje"}]
    end

    test "map is list" do
      m = [%{"address" => "Los Pinos B100"}, %{"address" => "Jejeje"}]
      assert Publit.Util.map_to_list(m) == m
    end

    test "map is list atom" do
      m = [%{"address" => "Los Pinos B100"}, %{"address" => "Jejeje"}]
      assert Publit.Util.map_to_list(m, :atom) == [%{address: "Los Pinos B100"}, %{address: "Jejeje"}]
    end

    test "map is list atom 2" do
      m = [%{address: "Los Pinos B100"}, %{address: "Jejeje"}]
      assert Publit.Util.map_to_list(m, :atom) == [%{address: "Los Pinos B100"}, %{address: "Jejeje"}]
    end
  end
end
