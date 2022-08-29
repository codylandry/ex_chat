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
      deps: deps()
    ]
  end

  def application do
    [
      mod: {ExChatDal, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.8"},
      {:postgrex, "~> 0.16.4"},
      {:bcrypt_elixir, "~> 1.1"}
    ]
  end
end
