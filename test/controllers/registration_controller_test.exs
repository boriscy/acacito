defmodule Publit.RegistrationControllerTest do
  use Publit.ConnCase

  setup do
    %{conn: build_conn}
  end

  describe "GET /registration" do
    test "OK", %{conn: conn} do
      conn = get(conn, "/registration")

      IO.inspect conn
      assert conn
    end
  end
end
