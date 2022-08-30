import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

config :ex_chat_dal, ExChatDal.Repo,
  pool: Ecto.Adapters.SQL.Sandbox

config :ex_chat_dal, ExUnit,
  seed: 1
