import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :white_rabbit_server, WhiteRabbitServer.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "white_rabbit_server_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :white_rabbit_server, WhiteRabbitServerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "f0//UAyIfG1ho0tRmPZuo0o9x2lcHUWSFu6J0l1VqXozjojRXboQiMJyWQLzlvae",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :white_rabbit_server, paypal_api_client: WhiteRabbitServer.PayPalAPI.InMemory
