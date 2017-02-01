defmodule Publit.TransApi.PositionControllerTest do
  use Publit.ConnCase

  setup do
    conn = build_conn()
    |> assign(:current_user_transport, insert(:user_transport))

    %{conn: conn}
  end

  @pos_attrs %{}

  describe "POST /trans_api/position" do
    test "OK", %{conn: conn} do
      conn = post(conn, "/trans_api/position", @pos_attrs)

      json = Poison.decode!(conn.resp_body)
    end
  end
end
