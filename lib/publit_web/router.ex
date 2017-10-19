defmodule PublitWeb.Router do
  use PublitWeb, :router

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
    plug PublitWeb.Plug.UserAuth
  end

  pipeline :organization_auth do
    plug PublitWeb.Plug.OrganizationAuth
  end

  pipeline :user_api_auth do
    plug PublitWeb.Plug.Api.UserAuth
  end

  pipeline :organization_api_auth do
    plug PublitWeb.Plug.Api.OrganizationAuth
  end



  ######################################################
  # Unauthorized API
  scope "/api", PublitWeb do
    pipe_through [:api]

    resources "/login", Api.LoginController, only: [:create, :delete]
    get "/valid_token/:token", Api.LoginController, :valid_token

    post "/validate_token", Api.SessionController, :validate_token
  end

  # Api that the organization accesses
  scope "/api", PublitWeb.Api do
    pipe_through [:api, :user_api_auth]


    # Authorized only for organizations
    scope "/" do
      pipe_through [:organization_api_auth]
      resources "/orders", OrderController, only: [:index, :show]
      put "/orders/:id/move_next", OrderController, :move_next
      put "/orders/:id/null", OrderController, :null
      put "/orders/:id/move_back", OrderController, :move_back

      get "/user_transport_position/:id", PositionController, :user_transport

      resources "/transport", TransportController, only: [:create, :delete]
    end

  end

  ######################################################
  pipeline :user_client_auth do
    plug PublitWeb.Plug.ClientApi.UserAuth
  end

  # API for clients
  scope "/client_api", PublitWeb.ClientApi do
    pipe_through [:api]
    post "/login", SessionController, :create
    post "/get_token", SessionController, :get_token
    # Registration
    post "/registration", RegistrationController, :create

    get "/:organization_id/products", ProductController, :products
    post "/search", SearchController, :search

    post "/validate_mobile", DeviceController, :validate
    post "/authenticate", DeviceController, :authenticate

    # Authorized API
    scope "/" do
      pipe_through [:user_client_auth]

      put "/device", DeviceController, :update

      get "/user_transport_position/:id", PositionController, :user_transport

      resources "/orders", OrderController

      resources "/comments", CommentController, only: [:create, :update]
      get "/comments/:order_id/comments", CommentController, :comments
    end
  end


  ######################################################
  pipeline :user_transport_auth do
    plug PublitWeb.Plug.TransApi.UserAuth
  end

  # API for transport
  scope "/trans_api", PublitWeb.TransApi do
    pipe_through [:api]

    post "/login", SessionController, :create
    post "/get_token", SessionController, :get_token
    get "/valid_token/:token", SessionController, :valid_token
    get "/get_user/:token", SessionController, :get_user

    post "/registration", RegistrationController, :create

    # Authorized API
    scope "/" do
      pipe_through [:user_transport_auth]

      put "/position", PositionController, :position
      put "/order_position", PositionController, :order_position
      put "/stop_tracking", PositionController, :stop_tracking

      put "/device", DeviceController, :update

      put "/accept/:order_id", OrderController, :accept
      put "/deliver/:order_id", OrderController, :deliver
      resources "/orders", OrderController, only: [:index]
    end
  end


  ######################################################
  # Site
  scope "/", PublitWeb do
    post "/mobile", MobileController, :create
  end

  scope "/", PublitWeb do
    pipe_through [:browser] # Use the default browser stack

    get "/", SessionController, :index
    get "/login", SessionController, :index
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete

    resources "/users", UserController
    resources "/registration", RegistrationController, only: [:index, :create]
  end


  # UserAuth
  scope "/", PublitWeb do
    pipe_through [:browser, :user_auth]
    get "/organizations", OrganizationController, :index
  end

  # OrganizationAuth
  scope "/", PublitWeb do
    pipe_through [:browser, :user_auth, :organization_auth]

    get "/dashboard", DashboardController, :index

    resources "/products", ProductController
    get "/products_frame", ProductController, :index_frame

    get "/organizations/images", OrganizationController, :edit_images
    put "/organizations/images", OrganizationController, :update_images
    get "/organizations/:id", OrganizationController, :show
    put "/organizations/open_close", OrganizationController, :open_close
    put "/organizations/current", OrganizationController, :update

    get "/orders", OrderController, :index
    get "/orders/list", OrderController, :list
  end
end
