defmodule Publit.UserTransportTest do
  use Publit.ModelCase

  alias Publit.UserTransport

  @valid_attrs %{full_name: "Julio Juarez", email: "julio@mail.com", password: "demo1234", mobile_number: "73732655", type: "jejeje"}
  @invalid_attrs %{email: "to", mobile_number: "22"}

  describe "create" do
    test "OK" do
      {:ok, user} = UserTransport.create(@valid_attrs)
      assert %UserTransport{} = user

      assert user.encrypted_password
      assert user.email == "julio@mail.com"
      assert user.mobile_number == "73732655"
    end

    test "Error invalid email, blank password" do
      {:error, cs} = UserTransport.create(@invalid_attrs)

      assert cs.valid? == false
      assert cs.errors[:email]
      assert cs.errors[:password]
      assert cs.errors[:full_name]
      assert cs.errors[:mobile_number]
    end
  end

  @fb_token "diFIABJ373k:APA91bGy81r8Gk9YYFTO5Sr-POcfsXkwP3dGD6xe8zT-7tgsk80pusIEp3KdPm4vxsNCb1Cb_KRElTY6p3ycDXNx1WXOgc7q7BgJp2PG4ctjjs79QxHHSzICEivpBiy5Xyfa1oe2Wy7Z"

  describe "update_fb_token" do
    test "OK" do
      {:ok, user} = UserTransport.create(@valid_attrs)

      {:ok, user} = UserTransport.update_fb_token(user, @fb_token)

      t = to_string(user.extra_data["fb_token_updated_at"])

      user = Repo.get(UserTransport, user.id)

      assert user.extra_data["fb_token"] == @fb_token
      assert user.extra_data["fb_token_updated_at"] == t
    end

    test "does not override " do
      {:ok, user} = Repo.insert(%UserTransport{
        full_name: "Juan Perez", mobile_number: "12345678", email: "juan@mail.com",
        encrypted_password: Comeonin.Bcrypt.hashpwsalt("demo1234"),
        extra_data: %{a: "data", b: 123, dec: 12.3, bool: true}
      })

      user = Repo.get(UserTransport, user.id)
      {:ok, user} = UserTransport.update_fb_token(user, @fb_token)

      user = Repo.get(UserTransport, user.id)

      assert user.extra_data["a"] == "data"
      assert user.extra_data["b"] == 123
      assert user.extra_data["dec"] == 12.3
      assert user.extra_data["bool"] == true


      assert user.extra_data["fb_token"] == @fb_token
      assert user.extra_data["fb_token_updated_at"]
    end
  end

end
