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

"""
Order.create(%{"organization_id" => org.id, details: %{
    "0" => %{"product_id" => p1.id, "variation_id" => v1.id, "quantity" => "1"},
  }
})
"""
