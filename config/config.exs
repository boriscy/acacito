# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :publit,
  ecto_repos: [Publit.Repo]

# Configures the endpoint
config :publit, PublitWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: PublitWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Publit.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :publit, PublitWeb.Gettext,
  default_locale: "es"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :arc,
  storage: Arc.Storage.Local

############################### weeks
config :publit, :session_max_age, 10 * 7 * 24 * 60 * 60
config :publit, :session_min_age, 7 * 24 * 60 * 60

config :publit, :sms_api, Publit.SmsApi

config :publit, :app_name, "Acacito"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
