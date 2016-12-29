defmodule Publit.Router do
  use Publit.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :user_auth do
    plug Publit.Plug.UserAuth
  end

  pipeline :organization_auth do
    plug Publit.Plug.OrganizationAuth
  end

  pipeline :user_api_auth do
    plug Publit.Plug.Api.UserAuth
  end

  pipeline :organization_api_auth do
    plug Publit.Plug.Api.OrganizationAuth
  end

  scope "/", Publit do
    pipe_through [:browser] # Use the default browser stack

    get "/", HomeController, :index
    get "/login", SessionController, :index
    post "/login", SessionController, :create
    delete "/logout", SessionController, :destroy

    resources "/users", UserController
    resources "/registration", RegistrationController, only: [:index, :create]
  end

  # UserAuth
  scope "/", Publit do
    pipe_through [:browser, :user_auth]
    get "/organizations", OrganizationController, :index
  end

  # OrganizationAuth
  scope "/", Publit do
    pipe_through [:browser, :user_auth, :organization_auth]

    get "/dashboard", DashboardController, :index

    resources "/products", ProductController

    get "/organizations/:id", OrganizationController, :show
    put "/organizations/current", OrganizationController, :update

    get "/work_area", WorkAreaController, :index
  end

  # Unauthorized API
  scope "/api", Publit do
    pipe_through [:api]

    post "/client_registration", Api.ClientRegistrationController, :create
    resources "/login", Api.LoginController, only: [:create, :delete]
    get "/valid_token/:token", Api.LoginController, :valid_token
  end

  # Api that the organization accesses
  scope "/api", Publit do
    pipe_through [:api, :user_api_auth]

    post "/orders", Api.OrderController, :create

    post "/search", Api.SearchController, :search
    get "/:organization_id/products", Api.ProductController, :products

    scope "/" do
      pipe_through [:organization_api_auth]
      get "/orders", Api.OrderController, :index
      get "/orders/:id", Api.OrderController, :show
    end

  end

end
