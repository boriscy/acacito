defmodule Publit.RegistrationControllerTest do
  use Publit.ConnCase
  alias Publit.{RegistrationService, User, Organization}

  setup do
    %{conn: build_conn() }
  end

  describe "GET /registration" do
    test "OK", %{conn: conn} do
      conn = get(conn, "/registration")

      assert conn.assigns.registration.data == %RegistrationService{}
      assert conn.assigns.valid == true
      assert view_template(conn) == "index.html"
    end
  end

  describe "POST /registration" do
    test "OK", %{conn: conn} do
      assert Enum.count(Repo.all(User)) == 0
      assert Enum.count(Repo.all(Organization)) == 0

      conn = post(conn, "/registration", %{"registration_service" =>
        %{
          "email" => "amaru@mail.com", "password"=> "demo1234", "mobile_number" => "59177112233",
          "name" => "La Pizzeria", "full_name" => "Amaru Barroso", "address"=> "Samaipata, frente al Jaguar Azul"
        }
      })

      assert redirected_to(conn) == "/dashboard"
      assert get_session(conn, "user_id")
      assert get_session(conn, "organization_id")


      user = Repo.all(User) |> List.first()
      org = Repo.all(Organization) |> List.first()

      assert org.category == "restaurant"

      user_org = user.organizations |> List.first()

      assert user_org.organization_id == org.id
      assert user_org.role == "admin"
      assert user_org.active == true
    end

    test "ERROR", %{conn: conn} do
      conn = post(conn, "/registration", %{"registration_service" =>
        %{
          "email" => "", "password"=> "demo1234",
          "name" => "La Pizzeria", "full_name" => "Amaru Barroso", "address"=> "Samaipata, frente al Jaguar Azul"
        }
      })

      assert view_template(conn) == "index.html"
      assert conn.assigns.valid == false
      assert conn.assigns.registration.valid? == false

      assert conn.assigns.registration.errors[:mobile_number]
    end
  end
end
