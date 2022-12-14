import Config

# For production, don't forget to configure the url host
# to something meaningful, Phoenix uses this information
# when generating URLs.
#
# Note we also include the path to a cache manifest
# containing the digested version of static files. This
# manifest is generated by the `mix phx.digest` task,
# which you should run after static files are built and
# before starting your production server.
config :ex_chat_web, ExChatWeb.Endpoint,
  url: [host: System.get_env("RENDER_EXTERNAL_HOSTNAME") || "localhost", port: 80],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :ex_chat_dal, ExChatDal.Repo,
  url: System.get_env("DATABASE_URL"),
  pool_size: 10

config :ex_chat_dal, ExChatDal.Mailer,
       adapter: Swoosh.Adapters.Sendinblue,
       api_key: System.get_env("SEND_IN_BLUE_API_KEY")

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :ex_chat_web, ExChatWeb.Endpoint,
#       ...,
#       url: [host: "example.com", port: 443],
#       https: [
#         ...,
#         port: 443,
#         cipher_suite: :strong,
#         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
#       ]
#
# The `cipher_suite` is set to `:strong` to support only the
# latest and more secure SSL ciphers. This means old browsers
# and clients may not be supported. You can set it to
# `:compatible` for wider support.
#
# `:keyfile` and `:certfile` expect an absolute path to the key
# and cert in disk or a relative path inside priv, for example
# "priv/ssl/server.key". For all supported SSL configuration
# options, see https://hexdocs.pm/plug/Plug.SSL.html#configure/1
#
# We also recommend setting `force_ssl` in your endpoint, ensuring
# no data is ever sent via http, always redirecting to https:
#
#     config :ex_chat_web, ExChatWeb.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# Do not print debug messages in production
config :logger, level: :info

# config :ex_chat_web, ExChatWeb.Endpoint,
#   server: true, # Without this line, your app will not start the web server!
#   load_from_system_env: true, # Needed for Phoenix 1.3. Doesn't hurt for other versions
#   http: [port: {:system, "PORT"}], # Needed for Phoenix 1.2 and 1.4. Doesn't hurt for 1.3.
#   secret_key_base: "${SECRET_KEY_BASE}",
#   url: [host: "${APP_NAME}.gigalixirapp.com", port: 443],
#   cache_static_manifest: "priv/static/cache_manifest.json",
#   version: Mix.Project.config[:version] # To bust cache during hot upgrades

# config :ex_chat_dal, ExChatDal.Repo,
#   adapter: Ecto.Adapters.Postgres,
#   url: "${DATABASE_URL}",
#   database: "", # Works around a bug in older versions of ecto. Doesn't hurt for other versions.
#   ssl: true,
#   pool_size: 2 # Free tier db only allows 4 connections. Rolling deploys need pool_size*(n+1) connections where n is the number of app replicas.

dns_name = System.get_env("RENDER_DISCOVERY_SERVICE")
app_name = System.get_env("RENDER_SERVICE_NAME")

config :libcluster,
  topologies: [
    render: [
      strategy: Cluster.Strategy.Kubernetes.DNS,
      config: [
        service: dns_name,
        application_name: app_name
      ]
    ]
  ]
