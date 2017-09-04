defmodule Publit.ClientApi.SearchControllerTest do
  use PublitWeb.ConnCase
  alias Publit.{UserClient, Organization}

  setup do
    conn = build_conn()
    |> assign(:current_user_client, %UserClient{full_name: "Amaru", id: "781d55f4-e055-4098-a0f5-fd4852db8db0"})

    %{conn: conn}
  end

  defp create_org(params) do
    name_u = String.replace(params[:name], " " ,"_")
    Repo.insert(%Organization{
      name: params[:name],
      pos: params[:pos],
      tags: params[:tags],
      rating: params[:rating] || 1,
      open: true,
      address: "address #{ :rand.uniform(100) }",
      images: [
        %Organization.Image{ctype: "list", filename: "#{name_u}.jpg"},
        %Organization.Image{ctype: "logo", filename: "#{name_u}.png"}
      ]
    })
  end

  defp coords(lng, lat) do
    %Geo.Point{coordinates: {lng, lat}, srid: nil}
  end
  def create_orgs do
    [
      # summa pacha
      create_org(%{name: "org 1", pos: coords(-18.1787804,-63.876047), rating: 4, tags: [%{text: "vegetariano", count: 10}, %{text: "vegano", count: 7}] }),
      #
      create_org(%{name: "org 2", pos: coords(-18.1767489,-63.8732718), rating: 3, tags: [%{text: "carne", count: 15}, %{text: "vegetariano", count: 1}, %{text: "parrilla", count: 5}] }),
      # Achira
      create_org(%{name: "org 3", pos: coords(-18.1650556,-63.8210238), rating: 5, tags: [%{text: "pizza", count: 20}, %{text: "pasta", count: 5}] }),
      create_org(%{name: "org 4", pos: coords(-18.1781923,-63.8660898), rating: 2, tags: [%{text: "pollo", count: 4}] }),
      # Timboy
      create_org(%{name: "org 5", pos: coords(-18.1767489,-63.8732718), rating: 3, tags: [] })
    ]
  end

  describe "POST /client_api/search" do
    test "radius 2 km", %{conn: conn} do
      create_orgs()

      conn = post(conn, "/client_api/search", %{"search" => %{"radius" => "2", "coordinates" => [-18.1778,-63.8748]}})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)
      assert json["results"] |> Enum.count() == 3

      org = json["results"] |> List.first

      img = org["images"] |> List.first()
      img2 =  img |> Map.put("organization_id", org["id"])
      |> Publit.Util.atomize_keys()

      assert img["ctype"] == "list"
      assert img["big"] == Organization.ImageUploader.path(img2, :big)
      assert img["thumb"] == Organization.ImageUploader.path(img2, :thumb)
    end
  end


  describe "POST /client_api/serch Authorization header" do
    test "OK" do
      create_orgs()
      user = insert(:user_client)
      token = Publit.UserAuthentication.encrypt_user_id(user.id)
      conn = build_conn() |> put_req_header("authorization", token)

      conn = post(conn, "/client_api/search", %{"search" => %{"radius" => "2", "coordinates" => [-18.1778,-63.8748]}})
      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)
      assert json["results"] |> Enum.count() == 3

    end
  end
end
