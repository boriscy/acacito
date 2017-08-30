use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :publit, Publit.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :publit, Publit.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "publit_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  types: Publit.PostgresTypes


#config :arc,
#  storage: Arc.Storage.Local

config :arc,
  storage: Arc.Storage.S3,
  bucket: "acacitotest"

config :ex_aws,
  access_key_id: System.get_env["AMAZON_KEY_ID"],
  secret_access_key: System.get_env["AMAZON_SECRET_KEY"],
  region: "sa-east-1",
  s3: [
    scheme: "https://",
    host: "s3-sa-east-1.amazonaws.com",
    region: "sa-east-1"
  ]


# in test/support/messaging_api_mock.ex
config :publit, :message_api, Publit.MessageApiMock

config :publit, :sms_api, Publit.SmsApiMock
