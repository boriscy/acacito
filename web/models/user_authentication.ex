defmodule Publit.UserAuthentication do
  @moduledoc """
  UserAuth is the module to verify user password to authenticate a user, can also
  decode a token and return the %User{} by it's id
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Publit.{UserAuthentication, User, Repo}

  embedded_schema do
    field :email
    field :password
  end

  @doc false
  @spec changeset(map) :: Struct.t
  def changeset(params \\ %{}) do
    cast(%UserAuthentication{}, params, [:email])
  end

  @doc """
  Validates user with params = %{"email" => "user@mail.com", "password" => "a-password"}
  """
  @spec valid_user(map) :: tuple
  def valid_user(params) do
    email = String.trim(params["email"] || "")

    with user <- Repo.get_by(User, email: email),
      false <- is_nil(user),
      true <- valid_password?(user, params["password"]) do
        {:ok, user}
    else
      _ -> {:error, changeset(params)}
    end
  end

  @doc """
  Recives a %User{} struct and creates a token
  """
  @spec encrypt_user(Struct.t) :: String.t
  def encrypt_user(user) do
    Phoenix.Token.sign(Publit.Endpoint, "user_id", user.id)
  end

  @doc """
  Gets the user by id decoding the token `user_id`
  """
  @spec get_user(String.t) :: tuple
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
