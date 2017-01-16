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
alias Publit.{Repo, User, UserClient, Organization, UserOrganization, Product, ProductVariation}

#org = Repo.insert(%Organization{
#  name: "Amalunchi",
#  currency: "BOB",
#  address: "Near cementary"
#})
pass = Comeonin.Bcrypt.hashpwsalt("demo1234")


{:ok, org} = Repo.insert(%Organization{
  name: "Tierra Libre",
  address: "Plaza principal samaipata",
  description: "Tierra Libre tiene la **mejor comida** en un lugar calido y hermoso donde encuetra la mejor comida y gran variedad.",
  rating: 4.5,  rating_count: 5,
  location: %Geo.Point{coordinates: {-63.8684321, -18.1898758}, srid: nil},
  tags: [], open: true
})

{:ok, user} = Repo.insert(%User{
  full_name: "Boris Barroso", email: "boris@example.com", encrypted_password: pass,
  organizations: [%UserOrganization{organization_id: org.id, role: "admin", name: "Tierra Libre"}]
})


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
  name: "Jugo de naranja",
  organization_id: org.id,
  publish: true,
  image: %Plug.Upload{content_type: "", filename: "juice1.jpg", path: "/home/boris/Pictures/comida/juice1.jpg"},
  tags: ["jugo", "naranja", "bebida"],
  description: "Deliciozo jugo de naranja.",
  variations: [%{name: "Vaso", price: Decimal.new("7")}, %{name: "Jarra", price: Decimal.new("20")}]
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

Organization.set_tags(org.id)

######################################################################################

{:ok, org} = Repo.insert(%Organization{
  name: "La Chakana",
  address: "Plaza principal samaipata",
  description: "Un lugar cerca del centro de samaipata con comida internacional de la mejor calidad",
  open: true, rating: 4.2,  rating_count: 3,
  location: %Geo.Point{coordinates: {-63.8784321, -18.1798758}, srid: nil},
  tags: [%{text: "carne", count: 10}, %{text: "vegetariano", count: 2}]
})

{:ok, user} = Repo.insert(%User{
  full_name: "Lucas Estrella", email: "lucas@mail.com", encrypted_password: pass,
  organizations: [%UserOrganization{organization_id: org.id, role: "admin", name: "Chakana"}]
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

Organization.set_tags(org.id)


################################################################
Repo.insert(%UserClient{
  full_name: "Amaru Barroso", email: "amaru@mail.com", encrypted_password: pass,
  mobile_number: "77889923"
})
Repo.insert(%UserClient{
  full_name: "Alvaro Luna", email: "alvaro@mail.com", encrypted_password: pass,
  mobile_number: "77889923"
})
Repo.insert(%UserClient{
  full_name: "Laura Gutierrez", email: "laura@mail.com", encrypted_password: pass,
  mobile_number: "77889923"
})


Ecto.Adapters.SQL.query(Repo, "UPDATE products SET publish=true")
