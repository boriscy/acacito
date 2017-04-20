defmodule Publit.ClientApi.RegistrationController do
  use Publit.Web, :controller
  plug :scrub_params, "user" when action in [:create]
  alias Publit.{UserClient, UserAuthentication, UserUtil, Repo}


  # POST /api/client_registration
  def create(conn, %{"user" => user_params}) do
    case UserClient.create(user_params) do
      {:ok, user} ->
        render(conn, "show.json", user: user)
      {:error, cs} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("errors.json", cs: cs)
    end
  end

  # PUT /api_client/validate_mobile_number
  def validate_mobile_number(conn, %{"id" => id, "verification_number" => verification_number}) do
    user = Repo.get(UserClient, id)

    if %UserClient{} = user do
      case UserUtil.verify_mobile_number(user, verification_number) do
        {:ok, user} ->
          render(conn, "show.json", user: user, token: UserAuthentication.encrypt_user_id(user.id))
        {:error, msg} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render("invalid_number.json", msg: msg)
      end
    else
      conn
      |> put_status(:not_found)
      |> render("not_found.json", msg: gettext("User not found"))
    end
  end

  # PUT /api_client/resend_verification_code/:id
  def resend_verification_code(conn, %{"id" => id, "mobile_number" => mobile_number}) do
    user = Repo.get(UserClient, id)

    if %UserClient{} = user do
      case UserUtil.resend_verification_code(user, mobile_number) do
        {:ok, user} ->
          render(conn, "show.json", user: user)
        {:error, cs} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render("errors.json", cs: cs)
      end
    else
      conn
      |> put_status(:not_found)
      |> render("not_found.json", msg: gettext("User not found"))
    end
  end

end
