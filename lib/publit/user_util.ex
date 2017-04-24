defmodule Publit.UserUtil do
  import Ecto.Changeset
  import Publit.Gettext
  alias Publit.{Repo}

  @max_retry 2

  @number_reg ~r|^591[6,7]\d{7}$|
  @numbers [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]

  def generate_random_numbers(l) do
    Enum.map((1..l), fn(_) -> Enum.random(@numbers) end) |> Enum.join("")
  end


  defp generate_encrypted_password(cs) do
    case cs do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(cs, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        cs
    end
  end

  def create_and_send_verification_code(cs) do
    ver_code = generate_random_numbers(6) |> to_string()

    resp = cs
    |> generate_encrypted_password()
    |> set_verification_data(ver_code)
    |> Publit.Repo.insert()

    case resp do
      {:ok, user} ->
        msg = gettext("Your %{app} code is: %{code}", app: app_name(), code: ver_code)
        Publit.SmsService.send_message(user.mobile_number, msg, ok_fn(user), error_fn(user))
      {:error, cs} ->
    end

    resp
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
