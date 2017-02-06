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


config :arc,
  storage: Arc.Storage.Local

# in test/support/messaging_api_mock.ex
config :publit, :message_api, Publit.MessageApiMock
