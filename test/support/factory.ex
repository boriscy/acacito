defmodule Publit.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Publit.Repo
  alias Publit.{Product, ProductVariation}

  def user_factory do
    %Publit.User{
      email: "lucas@mail.com",
      password: "demo1234",
      full_name: "Lucas Estrella",
      mobile_number: "59173731234",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234")
    }
  end

  def user_client_factory do
    %Publit.UserClient{
      email: "amaru@mail.com",
      full_name: "Amaru Barroso",
      password: "demo1234",
      mobile_number: "59173731234",
      extra_data: %{
        "device_token" => "devtokencli1234",
        "mobile_number_key" => Publit.AES.encrypt("123456"),
        "mobile_number_send_at" => to_string(DateTime.utc_now()),
        "mobile_number_sends" => 0
      },
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234")
    }
  end

  def user_transport_factory do
    %Publit.UserTransport{
      email: "juan@mail.com",
      full_name: "Juan Perez",
      password: "demo1234",
      mobile_number: "59166778899",
      vehicle: "motorcycle",
      plate: "HUT321",
      extra_data: %{
        "device_token" => "devtokentrans1234",
        "mobile_number_key" => Publit.AES.encrypt("123456"),
        "mobile_number_send_at" => to_string(DateTime.utc_now()),
        "mobile_number_sends" => 0
      },
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234")
    }
  end

  def organization_factory do
    %Publit.Organization{
      name: "Publit",
      currency: "BOB",
      address: "Calle 1 Near Here",
      pos: Geo.JSON.decode(%{"coordinates" => [-18.18, -63.87], "type" => "Point"})
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

  def order_factory do
    %Publit.Order{
      status: "new"
    }
  end

  def order_call_factory do
    %Publit.Order.Call{}
  end

  def order_log_factory do
    %Publit.Order.Log{}
  end

end
