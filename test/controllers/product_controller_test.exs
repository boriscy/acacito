defmodule Publit.ProductControllerTest do
  use Publit.ConnCase

  alias Publit.{Repo, Product}

  setup do
    conn = build_conn
    |> set_user_org_conn()

    %{conn: conn}
  end

  describe "GET /products" do
    test "OK", %{conn: conn} do
      conn = get(conn, "/products")

      assert conn.status == 200
    end
  end

  describe "GET /products/new" do
    test "OK", %{conn: conn} do
      conn = get(conn, "/products/new")

      assert view_template(conn) == "new.html"
      assert conn.status == 200
    end
  end

  @valid_attrs %{
    "name" => "Pizza", "price" => "40.5",
    "variations" => [%{"price"=> "-20", "name" => "Small", "description" => "Small size 10 x 10"}]
  }

  describe "POST /products" do
    test "OK", %{conn: conn} do
      assert Enum.count(Repo.all(Product)) == 0
      conn = post(conn, "/products", %{"product" => @valid_attrs})

      assert redirected_to(conn) == "/products"
      assert Enum.count(Repo.all(Product)) == 1
      assert get_flash(conn, :success)
    end

    test "ERROR", %{conn: conn} do
      attrs = Map.merge(@valid_attrs, %{"name" => ""})
      conn = post(conn, "/products", %{"product" => attrs})

      assert view_template(conn) == "new.html"
      assert get_flash(conn, :error)
      assert conn.status == Plug.Conn.Status.code(:unprocessable_entity)
    end
  end

  describe "GET /products/:id/edit" do
    test "OK", %{conn: conn} do
      prod = insert(:product, organization_id: conn.assigns.current_organization.id)
      conn = get(conn, "/products/#{prod.id}/edit")

      assert view_template(conn) == "edit.html"
      assert conn.status == 200
      p = conn.assigns.product

      assert p.id == prod.id
      assert p.name == prod.name
      assert p.variations == prod.variations

      assert view_template(conn) == "edit.html"
    end
  end

  describe "PUT /products/:id" do
    test "OK", %{conn: conn} do
      prod = insert(:product, organization_id: conn.assigns.current_organization.id)
      conn = put(conn, "/products/#{prod.id}", %{"product" => %{"name" => "New name",
        "variations" => %{"0" => %{"name" => "New variation", "price" => "111.5"} } } } )

      assert redirected_to(conn) == "/products"
      assert get_flash(conn, :success)

      prod = Repo.get(Product, prod.id)

      assert prod.name == "New name"
      [pv1] = prod.variations

      assert pv1.name == "New variation"
      assert pv1.price == Decimal.new("111.5")
    end

    test "ERROR", %{conn: conn} do
      prod = insert(:product, organization_id: conn.assigns.current_organization.id)
      conn = put(conn, "/products/#{prod.id}", %{"product" => %{"name" => "",
        "variations" => %{"0" => %{"name" => "New variation", "price" => "111.5"} } } } )

      assert get_flash(conn, :error)
      assert view_template(conn) == "edit.html"
    end

    test "User" do
      conn = build_conn |> set_user_org_conn(%{role: "user", email: "other@mail.com"})
      p_id = Ecto.UUID.generate()

      conn = put(conn, "/products/#{p_id}", %{"product" => %{"name" => "New name",
        "variations" => %{"0" => %{"name" => "New variation", "price" => "111.5"} } } } )

     assert redirected_to(conn) == "/products"
     assert get_flash(conn, :error)
    end
  end

  describe "DELETE /products/:id" do
    test "OK", %{conn: conn} do
      prod = insert(:product, organization_id: conn.assigns.current_organization.id)


      conn = delete(conn, "/products/#{prod.id}")

      assert redirected_to(conn) == "/products"
      assert get_flash(conn, :success)

      assert Repo.get(Product, prod.id) == nil
    end

    test "Error", %{conn: conn} do
      prod = insert(:product, organization_id: conn.assigns.current_organization.id, publish: true)

      conn = delete(conn, "/products/#{prod.id}")

      assert redirected_to(conn) == "/products"
      assert get_flash(conn, :error)

      assert Repo.get(Product, prod.id)
    end
  end

end
