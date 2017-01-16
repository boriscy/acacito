defmodule Publit.SearchServiceTest do
  use Publit.ModelCase

  alias Publit.{SearchService, Organization, Repo}

  defp create_org(params) do
    Repo.insert(%Organization{
      name: params[:name],
      location: params[:location],
      tags: params[:tags],
      rating: params[:rating] || 1,
      rating_count: params[:rating_count],
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
      create_org(%{name: "org 1", location: coords(-63.876047,-18.1787804), rating: 4, rating_count: 4,
        tags: [%{text: "vegetariano", count: 10}, %{text: "vegano", count: 7}], description: "Aaaa" }),
      #
      create_org(%{name: "org 2", location: coords(-63.8732718,-18.1767489), rating: 3, rating_count: 2,
        tags: [%{text: "carne", count: 15}, %{text: "vegetariano", count: 1}, %{text: "parrilla", count: 5}], description: "B" }),
      # Achira
      create_org(%{name: "org 3", location: coords(-63.8210238,-18.1650556), rating: 5, rating_count: 2,
        tags: [%{text: "pizza", count: 20}, %{text: "pasta", count: 5}] }),
      create_org(%{name: "org 4", location: coords(-63.8660898,-18.1781923), rating: 2.2, rating_count: 4,
        tags: [%{text: "pollo", count: 4}] }),
      # Timboy
      create_org(%{name: "org 5", location: coords(-63.8732718,-18.1767489), rating: 3, rating_count: 10, tags: [] })
    ]
  end

  describe "search" do
    test "radius 2" do
      create_orgs()

      rows = SearchService.search(%{
        "coordinates" => [-63.8748, -18.1778],
        "radius" => "2"
      })

      assert Enum.count(rows) == 3
      assert Enum.map(rows, fn(v) -> v[:name] end) |> Enum.sort() == ["org 1", "org 2", "org 4"]
    end

    test "radius 2 tags" do
      create_orgs()

      rows = SearchService.search(%{
        "coordinates" => [-63.8748, -18.1778],
        "radius" => "2", "tags" => ["vegano", "vegetariano"]
      })

      assert Enum.count(rows) == 2

      assert Enum.map(rows, &(&1.name)) |> Enum.sort() == ["org 1", "org 2"]
    end

    test "rating" do
      create_orgs()

      rows = SearchService.search(%{
        "coordinates" => [-63.8748, -18.1778],
        "radius" => "10", "rating" => "5", "tags" => ["vegano", "pizza"], "rating" => "5"
      })

      assert Enum.count(rows) == 1
      org = List.first(rows)
      assert org.name == "org 3"
      assert org.currency == "BOB"
      assert org.tags == [%{"count" => 20, "text" => "pizza"}, %{"count" => 5, "text" => "pasta"}]
      assert org.description == nil
      assert org.open
      assert org.rating == %Decimal{coef: 50, exp: -1, sign: 1}
      assert org.rating_count == 2
      assert org.id
      assert org.coords
    end

    test "rating integer" do
      create_orgs()

      rows = SearchService.search(%{
        "coordinates" => [-63.8748, -18.1778],
        "radius" => "10", "rating" => 5, "tags" => ["vegano", "pizza"], "rating" => "5"
      })

      assert Enum.count(rows) == 1
      org = List.first(rows)
      assert org.name == "org 3"
      assert org.currency == "BOB"
      assert org.tags == [%{"count" => 20, "text" => "pizza"}, %{"count" => 5, "text" => "pasta"}]
      assert org.description == nil
      assert org.open
      assert org.rating == %Decimal{coef: 50, exp: -1, sign: 1}
      assert org.rating_count == 2
      assert org.id
      assert org.coords
    end

    test "only rating" do
      create_orgs()

      rows = SearchService.search(%{
        "coordinates" => [-63.8748, -18.1778],
        "radius" => "2", "rating" => "4"
      })

      assert Enum.count(rows) == 1
      org = List.first(rows)

      assert org.name == "org 1"
      assert org.coords == %{"coordinates" => [-63.876047, -18.1787804], "type" => "Point"}
      assert org.id
      assert org.open == true
      assert org.rating == Decimal.new("4.0")
      assert org.rating_count == 4
      assert org.address
      assert org.tags == [%{"count" => 10, "text" => "vegetariano"}, %{"count" => 7, "text" => "vegano"}]
    end
  end
end
