# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Publit.Repo.insert!(%Publit.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Publit.{Repo, User, Organization, UserOrganization, Product, ProductVariation}

#org = Repo.insert(%Organization{
#  name: "Amalunchi",
#  currency: "BOB",
#  address: "Near cementary"
#})
"""
a = Repo.insert(%User{
  email: "amaru@mail.com",
  password: "demo1234",
  encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234"),
  organizations: %UserOrganization{
    active: true, role: "admin"
  }
})

v = Repo.insert(%User{
  email: "violeta@mail.com",
  password: "demo1234",
  encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234"),
  organizations: %UserOrganization{
    active: true, role: "admin"
  }
})

l = Repo.insert(%User{
  email: "lucas@mail.com",
  password: "demo1234",
  encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234"),
  organizations: %UserOrganization{
    active: true, role: "admin"
  }
})

org = Repo.get_by(Organization, name: "publit")
products = Product.published(conn.assigns.current_organization.id)

Order.create(%{"organization_id" => org.id, details: %{
    "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
  }
})
"""
org = Repo.get_by(Organization, name: "Tierra Libre")
if org do
  {:ok, prod} = Product.create(%{
    name: "Camaron al Ajo",
    organization_id: org.id,
    publish: true,
    image: %Plug.Upload{content_type: "", filename: "camaron-ajo.jpg", path: "/home/boris/Pictures/comida/camaron-ajo.jpg"},
    tags: ["mar", "camarones"],
    description: "Chicken breasts are filled with Gouda cheese and caramelized onions, rolled in seasoned coating mix, and baked until golden brown.",
    variations: [%{name: nil, price: Decimal.new("30")}]
  })

  {:ok, prod} = Product.create(%{
    name: "Pollo Parmessano",
    organization_id: org.id,
    publish: true,
    image: %Plug.Upload{filename: "pollo-a-parmesano.jpg", path: "/home/boris/Pictures/comida/pollo-a-parmesano.jpg"},
    tags: ["pollo", "queso", "comida italiana"],
    description: "Chicken breasts are filled with Gouda cheese and caramelized onions, rolled in seasoned coating mix, and baked until golden brown.",
    variations: [%{name: nil, price: Decimal.new("45")}]
  })

  {:ok, prod} = Product.create(%{
    name: "Sopa Tierra Libre",
    organization_id: org.id,
    publish: true,
    image: %Plug.Upload{content_type: "", filename: "sopa-1.jpg", path: "/home/boris/Pictures/comida/sopa-1.jpg"},
    tags: ["sopa", "carne"],
    description: "The best of 3 worlds. Rich, good and quick! This pie can be made in either an 8 or 9 inch pie pan.",
    variations: [%{name: nil, price: Decimal.new("30")}]
  })
end


{:ok, org} = Repo.insert(%Organization{
  name: "La Chakana",
  address: "Plaza principal samaipata",
  description: "Un lugar cerca del centro de samaipata con comida internacional de la mejor calidad",
  open: true, rating: 4.2,  rating_count: 3,
  geom: %Geo.Point{coordinates: {-63.8784321, -18.1798758}, srid: nil},
  tags: [%{text: "carne", count: 10}, %{text: "vegetariano", count: 2}]
})

{:ok, prod} = Product.create(%{
  name: "Goulash",
  organization_id: org.id,
  publish: true,
  image: %Plug.Upload{content_type: "", filename: "goulash.jpg", path: "/home/boris/Pictures/comida/goulash.jpg"},
  tags: ["sopa", "vegetariano"],
  description: "Chicken breasts are filled with Gouda cheese and caramelized onions, rolled in seasoned coating mix, and baked until golden brown.",
  variations: [%{name: nil, price: Decimal.new("30")}]
})

{:ok, prod} = Product.create(%{
  name: "Pollo con chanpiniones",
  organization_id: org.id,
  publish: true,
  image: %Plug.Upload{filename: "pollo-1.jpg", path: "/home/boris/Pictures/comida/pollo-1.jpg"},
  tags: ["pollo", "champiniones"],
  description: "Chicken breasts are filled with Gouda cheese and caramelized onions, rolled in seasoned coating mix, and baked until golden brown.",
  variations: [%{name: nil, price: Decimal.new("45")}]
})

{:ok, prod} = Product.create(%{
  name: "Stromboli",
  organization_id: org.id,
  publish: true,
  image: %Plug.Upload{content_type: "", filename: "stromboli.jpg", path: "/home/boris/Pictures/comida/stromboli.jpg"},
  tags: ["carne", "stromboli"],
  description: "The best of 3 worlds. Rich, good and quick! This pie can be made in either an 8 or 9 inch pie pan.",
  variations: [%{name: nil, price: Decimal.new("30")}]
})

"""

{;ok, org} = Repo.insert(%Organization{
  name: "Pollos OK",
  address: "Cerca a la estrellita",
  open: true
})
"""
