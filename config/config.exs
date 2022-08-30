# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :ex_chat_dal, ExChatDal.Repo,
  database: "ex_chat_#{Mix.env()}",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :ex_chat_dal,
  ecto_repos: [ExChatDal.Repo]

import_config "#{Mix.env()}.exs"
