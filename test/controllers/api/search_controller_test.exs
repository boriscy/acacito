defmodule Publit.Api.SearchControllerTest do
  use Publit.ConnCase
  alias Publit.{User}

  setup do
    conn = build_conn
    |> assign(:current_user, %User{full_name: "Amaru", id: "781d55f4-e055-4098-a0f5-fd4852db8db0"})

    %{conn: conn}
  end

  describe "POST /api/search" do
    test "radius 2 km", %{conn: conn} do
      conn = post(conn, "/api/search", %{"search" => %{"radius" => "2"}})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)
      IO.inspect json
    end
  end
end
