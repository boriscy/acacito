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

  pipeline :validate do
  end

  scope "/", Publit do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/login", SessionController, :index
    post "/login", SessionController, :create
    delete "/logout", SessionController, :destroy

    resources "/users", UserController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Publit do
  #   pipe_through :api
  # end
end
