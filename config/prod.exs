use Mix.Config

config :publit, Publit.Endpoint,
  http: [port: 42357],#System.get_env("PORT")],
  url: [scheme: "http", host: "acacito.com", port: 80],
  cache_static_manifest: "priv/static/manifest.json",
  # Distillery release config
  root: ".",
  server: true,
  version: Mix.Project.config[:version]


config :publit, Publit.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Do not print debug messages in production
config :logger, level: :info


# Configure your database
config :publit, Publit.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USERNAME"),
  password: System.get_env("DB_PASSWORD"),
  database: System.get_env("DB_DATABASE"),
  hostname: System.get_env("DB_HOSTNAME"),
  pool_size: 20,
  types: Publit.PostgresTypes


config :phoenix, :serve_endpoints, true


# arc
config :arc,
  storage: Arc.Storage.S3,
  bucket: "acacito"

# aws
config :ex_aws,
  access_key_id: System.get_env["AMAZON_KEY_ID"],
  secret_access_key: System.get_env["AMAZON_SECRET_KEY"],
  region: "sa-east-1",
  s3: [
    scheme: "https://",
    host: "s3-sa-east-1.amazonaws.com",
    region: "sa-east-1"
  ]

config :publit, :message_api, Publit.MessageApi
