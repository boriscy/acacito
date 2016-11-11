defmodule Publit.UserAuth do
  use Ecto.Schema
  import Ecto.Changeset

  alias Publit.{UserAuth, User, Repo}

  embedded_schema do
    field :email
    field :password
  end

  def changeset(params \\ %{}) do
    cast(%UserAuth{}, params, [:email])
  end

  def valid_user(params) do
    if params["email"] do
      case Repo.get_by(User, email: params["email"]) do
        nil -> {:error, changeset(params) }
        user ->
          if valid_password?(user, params["password"]) do
            {:ok, user}
          else
            {:error, changeset(params) }
          end
      end
    else
      {:error, changeset(params)}
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
