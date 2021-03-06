use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :publit, PublitWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  #cache_static_lookup: false,
  check_origin: false,
  watchers: [
    node: ["node_modules/brunch/bin/brunch", "watch", "--stdin",
           cd: Path.expand("../assets", __DIR__)]
  ]


# Watch static and templates for browser reloading.
config :publit, PublitWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/js/.*js$},
      ~r{priv/static/css/.*css$},
      ~r{priv/static/css/images/.*(png|jpeg|jpg|gif|svg)$},
      ~r{priv/static/images/.*(png|jpeg|jpg|gif|svg)$},
      ~r{priv/gettext/.*(po)$},
      ~r{lib/publit_web/views/.*(ex)$},
      ~r{lib/publit_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :publit, Publit.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("PUBLIT_USERNAME"),
  password: System.get_env("PUBLIT_PASSWORD"),
  database: System.get_env("PUBLIT_DATABASE"),
  hostname: System.get_env("PUBLIT_HOSTNAME"),
  pool_size: 10,
  types: Publit.PostgresTypes

config :arc,
  storage: Arc.Storage.S3,
  bucket: "acacitodev"

config :ex_aws,
  access_key_id: System.get_env["AMAZON_KEY_ID"],
  secret_access_key: System.get_env["AMAZON_SECRET_KEY"],
  region: "sa-east-1",
  s3: [
    scheme: "https://",
    host: "s3-sa-east-1.amazonaws.com",
    region: "sa-east-1"
  ]

config :publit, :message_api, Publit.MessageApiDev
# Host for push notifications and other stuff
config :publit, :domain, "acacito.pagekite.me"
