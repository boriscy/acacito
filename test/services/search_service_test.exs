defmodule Publit.SearchServiceTest do
  use Publit.ModelCase

  alias Publit.{SearchService, Organization, Repo}

  defp create_org(params) do
    Repo.insert(%Organization{
      name: params[:name],
      geom: params[:geom],
      tags: params[:tags],
      rating: params[:rating] || 1,
      open: true,
      address: "address #{ :rand.uniform(100) }"
    })
  end

  defp coords(lng, lat) do
    %Geo.Point{coordinates: {lng, lat}, srid: nil}
  end
  def create_orgs do
    [
      # summa pacha
      create_org(%{name: "org 1", geom: coords(-18.1787804,-63.876047), rating: 4, tags: [%{text: "vegetariano", count: 10}, %{text: "vegano", count: 7}] }),
      #
      create_org(%{name: "org 2", geom: coords(-18.1767489,-63.8732718), rating: 3, tags: [%{text: "carne", count: 15}, %{text: "vegetariano", count: 1}, %{text: "parrilla", count: 5}] }),
      # Achira
      create_org(%{name: "org 3", geom: coords(-18.1650556,-63.8210238), rating: 5, tags: [%{text: "pizza", count: 20}, %{text: "pasta", count: 5}] }),
      create_org(%{name: "org 4", geom: coords(-18.1781923,-63.8660898), rating: 2, tags: [%{text: "pollo", count: 4}] }),
      # Timboy
      create_org(%{name: "org 5", geom: coords(-18.1767489,-63.8732718), rating: 3, tags: [] })
    ]
  end

  describe "search" do
    test "radius 2" do
      create_orgs

      rows = SearchService.search(%{
        "coordinates" => [-18.1778,-63.8748],
        "radius" => "2"
      })

      assert Enum.count(rows) == 3
      assert Enum.map(rows, fn(v) -> v[:name] end) |> Enum.sort() == ["org 1", "org 2", "org 4"]
    end

    test "radius 2 tags" do
      create_orgs

      rows = SearchService.search(%{
        "coordinates" => [-18.1778,-63.8748],
        "radius" => "2", "tags" => ["vegano", "vegetariano"]
      })

      assert Enum.count(rows) == 2

      assert Enum.map(rows, &(&1.name)) |> Enum.sort() == ["org 1", "org 2"]
    end

    test "rating" do
      create_orgs

      rows = SearchService.search(%{
        "coordinates" => [-18.1778,-63.8748],
        "radius" => "10", "rating" => "5", "tags" => ["vegano", "pizza"], "rating" => "5"
      })

      assert Enum.count(rows) == 1
      org = List.first(rows)
      assert org.name == "org 3"
    end
  end
end
