defmodule Publit.ProductControllerTest do
  use PublitWeb.ConnCase

  alias Publit.{Repo, Product}

  setup do
    conn = build_conn()
    |> set_user_org_conn()

    %{conn: conn}
  end

  describe "GET /products" do
    test "OK", %{conn: conn} do
      conn = get(conn, "/products")

      assert conn.status == 200
    end
  end

  describe "GET /products/:id" do
    test "OK", %{conn: conn} do
      prod = insert(:product, organization_id: conn.assigns.current_organization.id)
      conn = get(conn, "/products/#{prod.id}")

      assert conn.status == 200
      assert view_template(conn) == "show.html"
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
    "name" => "Pizza",
    "variations" => %{"0" =>
      %{"price"=> "20", "name" => "Small", "description" => "Small size 10 x 10", "id" => nil}
    }
  }

  describe "POST /products" do
    test "OK", %{conn: conn} do
      assert Enum.count(Repo.all(Product)) == 0
      conn = post(conn, "/products", %{"product" => @valid_attrs})

      prods = Repo.all(Product)
      assert Enum.count(prods) == 1
      prod = List.first(prods)
      assert redirected_to(conn) == "/products/#{prod.id}"
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

    test "Admin user" do
      conn = build_conn() |> set_user_org_conn(%{role: "user", email: "other@mail.com", mobile_number: "66998822"})

      conn = post(conn, "/products", %{"product" => @valid_attrs})

     assert redirected_to(conn) == "/products"
     assert get_flash(conn, :error)
    end
  end

  describe "PUT /products/:id" do
    test "OK", %{conn: conn} do
      prod = insert(:product, organization_id: conn.assigns.current_organization.id)
      [pvar1 | _] = prod.variations
      conn = put(conn, "/products/#{prod.id}", %{"product" => %{"name" => "New name",
        "tags" => %{"0" => "multiple", "1" => "other"},
        "variations" => %{"0" =>
          %{"name" => "New variation", "price" => "111.5", "id" => pvar1.id} } } } )

      assert redirected_to(conn) == "/products/#{prod.id}"
      assert get_flash(conn, :success)

      prod = Repo.get(Product, prod.id)

      assert prod.name == "New name"
      assert prod.tags == ["multiple", "other"]
      [pv1] = prod.variations

      assert pv1.id == pvar1.id
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

    test "Admin user" do
      conn = build_conn() |> set_user_org_conn(%{role: "user", email: "other@mail.com", mobile_number: "21436587"})
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
      prod = insert(:product, organization_id: conn.assigns.current_organization.id, published: true)

      conn = delete(conn, "/products/#{prod.id}")

      assert redirected_to(conn) == "/products"
      assert get_flash(conn, :error)

      assert Repo.get(Product, prod.id)
    end

    test "Admin user" do
      conn = build_conn() |> set_user_org_conn(%{role: "user", email: "other@mail.com", mobile_number: "77998822"})
      p_id = Ecto.UUID.generate()

      conn = delete(conn, "/products/#{p_id}")

     assert redirected_to(conn) == "/products"
     assert get_flash(conn, :error)
    end
  end

end
