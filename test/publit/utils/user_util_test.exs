defmodule Publit.UserUtilTest do
  use Publit.ModelCase
  alias Publit.{UserClient, UserTransport, UserUtil, Repo}

  @cli_params %{"full_name" => "Amaru Barroso", "mobile_number" => "73732655"}
  @trans_params %{full_name: "Julio Juarez", mobile_number: "73732655", plate: "TUK123", vehicle: "motorcycle"}

  describe "set_mobile_verification_token" do
    test "OK client" do
      {:ok, uc} = Repo.insert(%UserClient{mobile_number: "73732655", full_name: "Amaru Barroso"})

      refute uc.mobile_verification_token

      {:ok, uc} = UserUtil.set_mobile_verification_token(UserClient, "73732655")

      assert "C-" <> t = uc.mobile_verification_token

      assert String.length(t) == 6
    end

    test "OK trans" do
      {:ok, ut} = Repo.insert(%UserTransport{mobile_number: "73732655", full_name: "Amaru Barroso"})

      refute ut.mobile_verification_token

      assert {:ok, ut} = UserUtil.set_mobile_verification_token(UserTransport, "73732655")

      assert "T-" <> t = ut.mobile_verification_token

      assert String.length(t) == 6
    end

    test "invalid" do
      assert :error = UserUtil.set_mobile_verification_token(UserClient, "73732655")
    end
  end

  describe "check_mobile_verification_token" do
    test "OK user_client" do
      {:ok, uc} = UserClient.create(%{mobile_number: "73732655", full_name: "Amaru Barroso"})

      assert "C-" <> _t = uc.mobile_verification_token

      assert {:ok, uc} = UserUtil.check_mobile_verification_token(uc.mobile_number, uc.mobile_verification_token)

      assert "VC-" <> _t = uc.mobile_verification_token
    end

    test "OK user_transport" do
      {:ok, ut} = UserTransport.create(%{mobile_number: "73732655", full_name: "Amaru Barroso"})

      assert "T-" <> _t = ut.mobile_verification_token

      assert {:ok, ut} = UserUtil.check_mobile_verification_token(ut.mobile_number, ut.mobile_verification_token)

      assert "VT-" <> _t = ut.mobile_verification_token
    end

    test "time" do
      {:ok, uc} = UserClient.create(%{"mobile_number" => "73732655", "full_name" => "Amaru Barroso"})
      t = NaiveDateTime.add(uc.mobile_verification_send_at, -3601)

      {:ok, uc} = Ecto.Changeset.change(uc) |> Ecto.Changeset.put_change(:mobile_verification_send_at, t) |> Repo.update()

      assert :error = UserUtil.check_mobile_verification_token("73732655", uc.mobile_verification_token)
    end

    test "invalid token" do
      {:ok, _uc} = UserClient.create(%{"mobile_number" => "73732655", "full_name" => "Amaru Barroso"})

      assert :error = UserUtil.check_mobile_verification_token("73732655", "je12345")
    end

    test "not found" do
      assert :error = UserUtil.check_mobile_verification_token("73732655", "je12345tt")
    end
  end

  describe "valid_mobile_verification_token" do
    test "OK user_client" do
      {:ok, uc} = UserClient.create(%{mobile_number: "73732655", full_name: "Amaru Barroso"})

      assert {:ok, _uc} = UserUtil.check_mobile_verification_token(uc.mobile_number, uc.mobile_verification_token)

      p = %{"mobile_number" => "73732655", "token" => uc.mobile_verification_token}
      assert %{user: user, token: token} = UserUtil.valid_mobile_verification_token(UserClient, p)

      assert "C-" <> _t = user.mobile_verification_token
      assert String.length(token) > 30
    end

    test "error user_client" do
      {:ok, uc} = UserClient.create(%{mobile_number: "73732655", full_name: "Amaru Barroso"})

      p = %{"mobile_number" => "73732655", "token" => uc.mobile_verification_token}
      assert :error = UserUtil.valid_mobile_verification_token(UserClient, p)
    end

    test "error no user" do
      p = %{"mobile_number" => "73732655", "token" => "C-123abc"}
      assert :error = UserUtil.valid_mobile_verification_token(UserClient, p)
    end

    test "OK user_transport" do
      {:ok, ut} = UserTransport.create(@trans_params)

      assert {:ok, _ut} = UserUtil.check_mobile_verification_token("73732655", ut.mobile_verification_token)

      p = %{"mobile_number" => "73732655", "token" => ut.mobile_verification_token}
      assert %{user: user, token: token} = UserUtil.valid_mobile_verification_token(UserTransport, p)

      assert "T-" <> _t = user.mobile_verification_token
      assert String.length(token) > 30
    end

  end

end

