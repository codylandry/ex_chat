defmodule ExChatDal.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_chat_dal,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(Mix.env())
    ]
  end

  def application do
    [
      mod: {ExChatDal, []},
      extra_applications: [:logger, :crypto]
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.8"},
      {:postgrex, "~> 0.16.4"},
      {:bcrypt_elixir, "~> 3.0"},
      {:swoosh, "~> 1.6"},
      {:gen_smtp, "~> 1.0"},
      {:hackney, "~> 1.9"}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases(:dev),
    do:
      aliases(:all) ++
        [
          "ecto.setup": [
            "ecto.create",
            "ecto.migrate",
            "run priv/repo/seeds.exs"
          ]
        ]

  defp aliases(_),
    do: [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
end
