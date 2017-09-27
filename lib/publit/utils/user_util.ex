defmodule Publit.UserUtil do
  import Ecto.Changeset
  import PublitWeb.Gettext
  alias Publit.{Repo, User, UserClient, UserTransport}

  @max_retry 2

  @number_reg ~r|^[6,7]\d{7}$|
  @numbers [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
  @downcase_letters ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
  @upcase_letters ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

  @all_chars @numbers ++ @downcase_letters ++ @upcase_letters

  def generate_random_numbers(l) do
    Enum.map((1..l), fn(_) -> Enum.random(@numbers) end) |> Enum.join("")
  end

  def generate_random_string(l) do
    Enum.map((1..l), fn(_) -> Enum.random(@all_chars) end) |> Enum.join("")
  end

  defp generate_encrypted_password(cs) do
    case cs do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(cs, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        cs
    end
  end

  @doc """
  Sets the user token to login later for UserClient,
  """
  @type set_mobile_verification_token(struct :: UserClient.t | UserTransport.t | User.t, mobile_number :: binary) :: tuple
  def set_mobile_verification_token(struct, mobile_number) do
    case Repo.get_by(struct, mobile_number: mobile_number) do
      nil -> :error
      u ->
        token = generate_token(struct)

        change(u)
        |> put_change(:mobile_verification_token, token)
        |> put_change(:mobile_verification_send_at, NaiveDateTime.utc_now())
        |> Repo.update()
    end
  end

  @doc """
  Checks if the mobile_verification_token is valida and updates to valid
  """
  def check_mobile_verification_token(mobile_number, token) do
    with struct <- get_struct(token),
      false <- is_nil(struct),
      u <- Repo.get_by(struct, mobile_number: mobile_number),
      false <- is_nil(u),
      true <- u.mobile_verification_token == token  && NaiveDateTime.diff(NaiveDateTime.utc_now, u.mobile_verification_send_at) <= 3600 do
        change(u)
        |> put_change(:verified, true)
        |> put_change(:mobile_verification_token, "V" <> token)
        |> Repo.update()
    else
      _ ->
        :error
    end
  end

  @doc """
  Checks if the mobile_verification_token has been validated and returns a token
  with the user_id
  """
  @type valid_mobile_verification_token(struct :: UserClient.t | UserTransport.t | User.t, params :: map) :: map
  def valid_mobile_verification_token(struct, params) do
    with u <- Repo.get_by(struct, mobile_number: params["mobile_number"]),
      false <- is_nil(u),
      true  <- Regex.match?(~r/^V#{params["token"]}/, u.mobile_verification_token),
      {:ok, user} <- reset_mobile_verification_token(u) do
        %{user: user, token: Phoenix.Token.sign(PublitWeb.Endpoint, "user_id", u.id) }
    else
      _ ->
       :error
    end
  end

  def reset_mobile_verification_token(user) do
    token = generate_token(user.__struct__)

    change(user)
    |> put_change(:mobile_verification_token, token)
    |> put_change(:mobile_verification_send_at, NaiveDateTime.utc_now())
    |> Repo.update()
  end

  defp get_prefix(struct) do
    case struct do
      UserClient -> "C-"
      UserTransport -> "T-"
      User -> "O-"
    end
  end

  defp get_struct(token) do
    case token do
      "C-" <> _ -> UserClient
      "T-" <> _ -> UserTransport
      "O-" <> _ -> User
      _ -> nil
    end
  end

  defp generate_token(struct) do
    get_prefix(struct) <> generate_random_string(6) |> to_string()
  end

  defp get_keys(params, keys) do
    Enum.map(keys, fn(key) ->
      Map.get(params, key) |> to_string()
    end)
  end

  def create_and_set_verification_token(cs) do
    token = generate_token(cs.data.__struct__)

    cs
    |> put_change(:mobile_verification_token, token)
    |> put_change(:mobile_verification_send_at, NaiveDateTime.utc_now())
    |> Publit.Repo.insert()
  end

  def verify_mobile_number(user, mobile_number_key) do
    m_num = Publit.AES.decrypt(user.extra_data["mobile_number_key"])

    with true <- m_num == mobile_number_key do
      change(user)
      |> put_change(:verified, true)
      |> Repo.update()
    else
      _ ->
        {:error, gettext("Invalid verification code")}
    end
  end

  def resend_verification_code(user, number) do
    if user.extra_data["mobile_number_sends"] < @max_retry do
      m_ver_num = generate_random_numbers(6) |> to_string()

      ed = Map.merge(user.extra_data, %{"mobile_number_key" => Publit.AES.encrypt(m_ver_num)})

      resp = change(user)
      |> put_change(:mobile_number, number)
      |> put_change(:extra_data, ed)
      |> validate_format(:mobile_number, @number_reg)
      |> Repo.update()

      case resp do
        {:ok, user} ->
          msg = gettext("Your %{app} code is: %{code}", app: app_name(), code: m_ver_num)
          Publit.SmsService.send_message(user.mobile_number, msg, ok_fn(user), error_fn(user))
          {:ok, user}
        _ ->
          resp
      end
    else
      {:error, gettext("You have reached the max retries verifications for the day, please try in 24 hours")}
    end
  end

  defp set_verification_data(cs, num) do
    enc = num
    |> to_string()
    |> Publit.AES.encrypt()

    ed = Map.merge(cs.data.extra_data, %{
      "mobile_number_key" => enc,
      "mobile_number_send_at" => to_string(DateTime.utc_now()),
      "mobile_number_sends" => 0
    })

    cs |> put_change(:extra_data, ed)
  end

  defp ok_fn(user), do: cb_fun(user, true)

  defp error_fn(user), do: cb_fun(user, false)

  defp cb_fun(user, val) do
    fn (_resp) ->
      user = get_updated_user(user)
      ed = Map.merge(user.extra_data, %{
        "mobile_number_sends" => 1 + (user.extra_data["mobile_number_sends"] || 0),
        "mobile_number_send_ok" => val
      })

      change(user)
      |> put_change(:extra_data, ed)
      |> Repo.update()
    end
  end

  defp get_updated_user(user) do
    case user do
      %Publit.User{} -> Repo.get(Publit.User, user.id)
      %Publit.UserClient{} -> Repo.get(Publit.UserClient, user.id)
      %Publit.UserTransport{} -> Repo.get(Publit.UserTransport, user.id)
    end
  end

  defp app_name, do: Application.get_env(:publit, :app_name)

end
