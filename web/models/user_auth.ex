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
    Phoenix.Token.sign(Publit.Endpoint, "user_id", user.id)
  end

  def get_user(user_id) do
    case Phoenix.Token.verify(Publit.Endpoint, "user_id", user_id) do
      {:ok, user_id} ->
        Repo.get(User, user_id)
      {:error, :invalid} ->
        nil
    end
  end

  defp valid_password?(user, password) do
    Comeonin.Bcrypt.checkpw(password, user.encrypted_password)
  end
end
