defmodule PublitWeb.SessionMacro do

  defmacro __using__(opts) do

    quote do
      def opts do
        unquote(opts[:struct])
      end

      use PublitWeb, :controller
      plug :scrub_params, "auth" when action in [:token]


      # POST /route/login
      def create(conn, %{"mobile_number" => mobile_number}) do
        case Publit.UserUtil.set_mobile_verification_token(opts()[:struct], mobile_number) do
          {:ok, uc} ->
            render(conn, "show.json", user: uc)
          _ ->
            conn
            |> put_status(:not_found)
            |> render("error.json", msg: gettext("Mobile number not found"))
        end
      end

      # POST /route/get_token
      def get_token(conn, %{"auth" => params}) do
        case Publit.UserUtil.valid_mobile_verification_token(opts()[:struct], params) do
          %{user: user, token: token} ->
            render(conn, "show.json", user: user, token: token)
          _ ->
            conn
            |> put_status(:unprocessable_entity)
            |> render("error.json")
        end
      end

    end

  end

end
