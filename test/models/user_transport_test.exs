defmodule Publit.UserTransportTest do
  use Publit.ModelCase

  alias Publit.UserTransport

  @valid_attrs %{full_name: "Julio Juarez", email: "julio@mail.com",
   password: "demo1234", mobile_number: "73732655", plate: "TUK123", vehicle: "motorcycle"}
  @invalid_attrs %{email: "to", mobile_number: "22", status: "invalid status"}

  describe "create" do
    test "OK" do
      {:ok, user} = UserTransport.create(@valid_attrs)
      assert %UserTransport{} = user

      assert user.encrypted_password
      assert user.email == "julio@mail.com"
      assert user.mobile_number == "73732655"
      assert user.status == "off"
      assert user.vehicle == "motorcycle"
    end

    test "Error invalid email, blank password" do
      {:error, cs} = UserTransport.create(@invalid_attrs)

      assert cs.valid? == false
      assert cs.errors[:email]
      assert cs.errors[:password]
      assert cs.errors[:full_name]
      assert cs.errors[:mobile_number]
    end

    test "plate validation" do
      {:error, cs} = UserTransport.create(%{plate: "", vehicle: "car"})
      assert cs.errors[:plate]

      {:error, cs} = UserTransport.create(%{plate: "SD", vehicle: "motorcycle"})
      assert cs.errors[:plate]

      {:error, cs} = UserTransport.create(%{plate: "SD3", vehicle: "motorcycle"})
      refute cs.errors[:plate]

      {:error, cs} = UserTransport.create(%{plate: "", vehicle: "walk"})

      refute cs.errors[:plate]
    end
  end

  @player_id "e95fb4a9-50d3-41ae-a8d3-1465f00611e6"

  describe "OpenSignal" do
    test "update_player_id" do
      {:ok, user} = UserTransport.create(@valid_attrs)

      {:ok, user} = UserTransport.update_os_player_id(user, @player_id)

      t = to_string(user.extra_data["os_updated_at"])

      user = Repo.get(UserTransport, user.id)

      assert user.extra_data["os_player_id"] == @player_id
      assert user.extra_data["os_updated_at"] == t
    end

    test "update_os_player_id does not override " do
      {:ok, user} = Repo.insert(%UserTransport{
        full_name: "Juan Perez", mobile_number: "12345678", email: "juan@mail.com",
        encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234"),
        extra_data: %{a: "data", b: 123, dec: 12.3, bool: true}
      })

      user = Repo.get(UserTransport, user.id)
      {:ok, user} = UserTransport.update_os_player_id(user, @player_id)

      user = Repo.get(UserTransport, user.id)

      assert user.extra_data["a"] == "data"
      assert user.extra_data["b"] == 123
      assert user.extra_data["dec"] == 12.3
      assert user.extra_data["bool"] == true


      assert user.extra_data["os_player_id"] == @player_id
      assert user.extra_data["os_updated_at"]
    end

  end

  describe "get_by_email_or_mobile" do
    test "OK mobile_number" do
      {:ok, _user} = UserTransport.create(@valid_attrs)

      user1 = UserTransport.get_by_email_or_mobile(@valid_attrs[:mobile_number])
      user2 = UserTransport.get_by_email_or_mobile(@valid_attrs[:email])

      assert user1 == user2
    end
  end

  describe "update_position" do
    #@valid_pos %{"accuracy" => 8, "altitude" => 1687, "heading" => -1, "latitude" => -63.8736857, "longitude" => -63.8736867, "speed" => 20}
    test "OK" do
      pos = %{"coordinates" => [-17.8145819, -63.1560853], "type" => "Point"}
      user = insert(:user_transport)

      assert user.pos == nil

      assert {:ok, user} = UserTransport.update_position(user, %{"pos" => pos, "speed" => 30})

      assert user.pos == %Geo.Point{coordinates: {-17.8145819, -63.1560853}, srid: nil}
      assert user.status == "listen"
    end

    test "invalid" do
      pos = %{"coordinates" => [-182.8145819, -63.1560853], "type" => "Point"}
      user = insert(:user_transport)

      assert {:error, _cs} = UserTransport.update_position(user, %{"pos" => pos})

      pos = %{"coordinates" => [182.8145819, -63.1560853], "type" => "Point"}

      assert {:error, _cs} = UserTransport.update_position(user, %{"pos" => pos})

      pos = %{"coordinates" => [82.8145819, -93.1560853], "type" => "Point"}

      assert {:error, _cs} = UserTransport.update_position(user, %{"pos" => pos})

      pos = %{"coordinates" => [182.8145819, 93.1560853], "type" => "Point"}

      assert {:error, cs} = UserTransport.update_position(user, %{"pos" => pos})

      assert cs.errors[:pos]
    end

    test "invalid no pos" do
      user = insert(:user_transport)
      assert {:error, _cs} = UserTransport.update_position(user, %{"pos" => %{}})
    end

  end

  describe "stop_tracking" do
    test "OK" do
      user = insert(:user_transport, %{status: "listen"})
      assert user.status == "listen"

      {:ok, user} = UserTransport.stop_tracking(user)
      assert user.status == "off"
    end

    test "ERROR" do
      user = insert(:user_transport, %{status: "order"})
      assert user.status == "order"

      {:error, cs} = UserTransport.stop_tracking(user)
      assert cs.errors[:status]
    end
  end


end
