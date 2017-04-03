defmodule Publit.TransApi.PushyControllerTest do
  use Publit.ConnCase
  alias Publit.{UserTransport}

  setup do
    conn = build_conn()
    |> assign(:current_user_transport, user())

    %{conn: conn}
  end

  defp user do
    {:ok, u} = Repo.insert(%UserTransport{email: "juan@mail.com", mobile_number: "12345678",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo4321")} )
    u
  end

  @device_token "14d14fa953ac53aaff8416"

  describe "PUT /trans_api/puhsy" do
    test "OK", %{conn: conn} do
      conn = put(conn, "/trans_api/pushy", %{"device_token" => @device_token})

      assert conn.status == 200
      json = Poison.decode!(conn.resp_body)

      assert json["user"]["id"] == conn.assigns[:current_user_transport].id
    end

    test "ERROR" do
      conn = build_conn()
      conn = put(conn, "/trans_api/pushy", %{"device_token" => @device_token})

      assert conn.status == Plug.Conn.Status.code(:unauthorized)
      json = Poison.decode!(conn.resp_body)

      assert json["message"] == gettext("You need to login")
    end
  end

end

