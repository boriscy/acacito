defmodule Publit.UserUtilTest do
  use Publit.ModelCase
  alias Publit.{UserClient, UserUtil, Repo}

  describe "set_token" do
    test "OK" do
      {:ok, uc} = Repo.insert(%UserClient{mobile_number: "73732655", full_name: "Amaru Barroso"})

      refute uc.mobile_verification_token

      {:ok, uc} = UserUtil.set_mobile_verification_token(UserClient, "73732655")

      assert uc.mobile_verification_token
    end

    test "invalid" do
      assert :error = UserUtil.set_mobile_verification_token(UserClient, "73732655")
    end
  end

end

