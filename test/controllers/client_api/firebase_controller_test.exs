defmodule Publit.ClientApi.FirebaseControllerTest do
  use Publit.ConnCase
  alias Publit.{UserClient}

  setup do
    uc = insert(:user_client)
    conn = build_conn()
    |> assign(:current_user_client, uc)

    %{conn: conn}
  end

  describe "PUT /cli_api/firebase" do
    test "OK", %{conn: conn} do
      conn = put(conn, "/client_api/firebase", %{"token" => "demo4321"})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert json["user"]["id"] == conn.assigns[:current_user_client].id
    end

    test "ERROR" do
      conn = build_conn()
      conn = put(conn, "/client_api/firebase", %{"token" => "demo4321"})

      assert conn.status == Plug.Conn.Status.code(:unauthorized)
      json = Poison.decode!(conn.resp_body)

      assert json["message"] == gettext("You need to login")
    end
  end

end


