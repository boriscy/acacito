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
    delete "/logout", SessionController, :delete

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

    resources "/login", Api.LoginController, only: [:create, :delete]
    get "/valid_token/:token", Api.LoginController, :valid_token
  end

  # Api that the organization accesses
  scope "/api", Publit.Api do
    pipe_through [:api, :user_api_auth]


    # Authorized only for organizations
    scope "/" do
      pipe_through [:organization_api_auth]
      resources "/orders", OrderController, only: [:index, :show]
      put "/orders/:id/move_next", OrderController, :move_next
    end

  end

  pipeline :client_user_auth do
    plug Publit.Plug.ClientApi.UserAuth
  end

  # API for clients
  scope "/client_api", Publit.ClientApi do
    # Unauthorized API
    pipe_through [:api]
    post "/login", SessionController, :create
    delete "/login", SessionController, :delete
    get "/valid_token/:token", SessionController, :valid_token
    post "/registration", RegistrationController, :create
    # Authorized API
    scope "/" do
      pipe_through [:client_user_auth]

      get "/:organization_id/products", ProductController, :products
      post "/search", SearchController, :search
      resources "/orders", OrderController
    end
  end

  # API for transport
  scope "/trans_api", Publit do

  end

end
