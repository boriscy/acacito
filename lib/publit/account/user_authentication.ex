defmodule Publit.UserAuthentication do
  @moduledoc """
  UserAuth is the module to verify user password to authenticate a user, can also
  decode a token and return the %User{} by it's id
  """
  use Ecto.Schema
  import Ecto.Changeset
  import PublitWeb.Gettext

  alias Publit.{UserAuthentication, User, UserClient, UserTransport, Repo, Gettext}

  @max_age Application.get_env(:publit, :session_max_age)

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
      {:pass, true} <- {:pass, valid_password?(user.encrypted_password, params["password"])} do
        {:ok, user}
    else
      {:user, _} ->
        cs = changeset(params) |> add_error(:email, "Invalid email or mobile number")
        {:error, cs}
      {:pass, _} ->
        cs = changeset(params) |> add_error(:password, "Invalid password")
        {:error, cs}
    end
  end

  def valid_user_transport(params) do
    mobile_number = String.trim(params["mobile_number"] || "")

    with user <- Repo.get_by(UserTransport, mobile_number: mobile_number),
      {:user, false} <- {:user, is_nil(user)},
      {:pass, true} <- {:pass, valid_password?(user.encrypted_password, params["password"])} do
        {:ok, user}
    else
      {:user, _} -> {:error, changeset(params) |> add_error(:mobile_number, "Invalid mobile number")}
      {:pass, _} -> {:error, changeset(params) |> add_error(:password, "Invalid password") }
    end
  end

  defp valid_user(schema, params) do
    email = String.trim(params["email"] || "")

    with user <- Repo.get_by(schema, email: email, verified: true),
      {:email, false} <- {:email, is_nil(user)},
      {:pass, true} <- {:pass, valid_password?(user.encrypted_password, params["password"])} do
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
  @spec encrypt_user_id(String.t) :: String.t
  def encrypt_user_id(user_id) do
    Phoenix.Token.sign(PublitWeb.Endpoint, "user_id", user_id)
  end


  @doc """
  Recives an id and adds the time
  """
  @spec get_new_token(String.t, String.t) :: String.t
  def get_new_token(user_id, token) do
    case Phoenix.Token.verify(PublitWeb.Endpoint, "user_id", token, max_age: min_age()) do
      {:ok, _user_id} ->
        token
      {:error, :expired} ->
        Phoenix.Token.sign(PublitWeb.Endpoint, "user_id", user_id)
    end
  end


  @doc """
  Gets the user by id decoding the token `user_id`
  """
  @spec get_user(String.t) :: tuple
  def get_user(user_id) do
    case Phoenix.Token.verify(PublitWeb.Endpoint, "user_id", user_id, max_age: @max_age) do
      {:ok, user_id} ->
        Repo.get(User, user_id)
      {:error, :invalid} ->
        nil
    end
  end

  # required to mock
  defp min_age do
    Application.get_env(:publit, :session_min_age)
  end

  defp valid_password?(enc_pass, pass) when is_binary(enc_pass) and is_binary(pass) do
    Comeonin.Bcrypt.checkpw(pass, enc_pass)
  end
  defp valid_password?(_a, _b), do: false
end
