defmodule Publit.UserAuthentication do
  @moduledoc """
  UserAuth is the module to verify user password to authenticate a user, can also
  decode a token and return the %User{} by it's id
  """
  use Ecto.Schema
  import Ecto.Changeset
  import Publit.Gettext

  alias Publit.{UserAuthentication, User, UserClient, UserTransport, Repo, Gettext}

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
    valid_user(User, params)
  end

  @doc """
  Validates user_client with params = %{"email" => "user@mail.com", "password" => "a-password"}
  """
  @spec valid_user_client(map) :: tuple
  def valid_user_client(params) do
    email_or_mobile = String.trim(params["email"] || "")

    with user <- UserClient.get_by_email_or_mobile(email_or_mobile),
      {:user, false} <- {:user, is_nil(user)},
      {:pass, true} <- {:pass, valid_password?(user, params["password"])} do
        {:ok, user}
    else
      {:user, _} ->
        cs = changeset(params) |> add_error(:email, "Invalid email")
        {:error, cs}
      {:pass, _} ->
        cs = changeset(params) |> add_error(:password, "Invalid password")
        {:error, cs }
    end
  end

  def valid_user_transport(params) do
    email_or_mobile = String.trim(params["email"] || "")

    with user <- UserTransport.get_by_email_or_mobile(email_or_mobile),
      {:user, false} <- {:user, is_nil(user)},
      {:pass, true} <- {:pass, valid_password?(user, params["password"])} do
        {:ok, user}
    else
      {:user, _} -> {:error, changeset(params) |> add_error(:email, "Invalid email")}
      {:pass, _} -> {:error, changeset(params) |> add_error(:password, "Invalid password") }
    end
  end

  defp valid_user(schema, params) do
    email = String.trim(params["email"] || "")

    with user <- Repo.get_by(schema, email: email),
      {:email, false} <- {:email, is_nil(user)},
      {:pass, true} <- {:pass, valid_password?(user, params["password"])} do
        {:ok, user}
    else
      {:email, _} ->
        cs = changeset(params) |> add_error(:email, gettext("Invalid email"))
        {:error, cs}
      {:pass, _} ->
        cs = changeset(params) |> add_error(:password, gettext("Invalid password"))
        {:error, cs}
    end
  end

  @doc """
  Recives a %User{} struct and creates a token wit just the id
  """
  @spec encrypt_user_id(Struct.t) :: String.t
  def encrypt_user_id(id) do
    Phoenix.Token.sign(Publit.Endpoint, "user_id", id)
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
