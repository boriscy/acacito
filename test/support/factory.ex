defmodule Publit.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Publit.Repo
  alias Publit.{Product, ProductVariation}

  def user_factory do
    %Publit.User{
      email: "amaru@mail.com",
      password: "demo1234",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234")
    }
  end

  def user_client_factory do
    %Publit.UserClient{
      email: "amaru@mail.com",
      password: "demo1234",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234")
    }
  end

  def organization_factory do
    %Publit.Organization{
      name: "Publit",
      currency: "BOB",
      address: "Calle 1 Near Here",
      location: Geo.JSON.decode(%{"coordinates" => [-18.18, -63.87], "type" => "Point"})
    }
  end

  def product_factory do
    %Product{
      name: "Pizza",
      variations: [
        %ProductVariation{price: Decimal.new("20"), name: "Small"},
        %ProductVariation{price: Decimal.new("30"), name: "Medium"},
        %ProductVariation{price: Decimal.new("40"), name: "Big"}
      ]
    }
  end
end
