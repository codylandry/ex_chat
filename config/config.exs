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

config :ex_chat_web,
  generators: [context_app: :ex_chat_dal]

# Configures the endpoint
config :ex_chat_web, ExChatWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ExChatWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ExChatOtp.PubSub,
  live_view: [signing_salt: "Z9u9fk57"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/ex_chat_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :ex_chat_dal, ExChatDal.Mailer,
  adapter: Swoosh.Adapters.Sendinblue,
  api_key: System.get_env("SEND_IN_BLUE_API_KEY")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../apps/ex_chat_web/assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
