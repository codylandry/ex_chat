import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

config :ex_chat_dal, ExChatDal.Repo,
       pool: Ecto.Adapters.SQL.Sandbox

config :ex_chat_dal, ExUnit,
       seed: 1

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :ex_chat_web, ExChatWeb.Endpoint,
       http: [ip: {127, 0, 0, 1}, port: 4002],
       secret_key_base: "eQjKiknONWHombLWHfH9VvSRIbN0Hhz6Agn2Ny+k2r4bRNJBeT2P7tqIXq31H59E",
       server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
