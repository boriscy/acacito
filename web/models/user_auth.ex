defmodule Publit.UserAuth do
  defstruct [:email, :password]

  alias Publit.{UserAuth, User, Repo}

  def changeset(params \\ %{}) do
    %UserAuth{email: params["email"]}
  end

  def valid_user(params) do
    case Repo.get_by(User, email: params["email"]) do
      nil -> {:error, changeset(params) }
      user ->
        if valid_password?(user, params["password"]) do
          {:ok, user}
        else
          {:error, changeset(params) }
        end
    end
  end

  def encrypt_user(user) do
    #Phoenix.Token.sign(:user_id, )
  end

  defp valid_password?(user, password) do
    Comeonin.Bcrypt.checkpw(password, user.encrypted_password)
  end
end
