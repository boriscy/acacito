defmodule Publit.TransportControllerTest do
  use Publit.ConnCase

  setup do
    {user, org} = create_user_org()
    conn = build_conn()
    |> assign(:current_user, user)
    |> assign(:current_organization, org)

    %{conn: conn, user: user, org: org}
  end

  describe "POST /api/transport" do
    test "OK" do

    end
  end
end
