defmodule ExChatOtp.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_chat_otp,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [
        "test.watch": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :phoenix_pubsub],
      mod: {ExChatOtp.Application, []}
    ]
  end

  defp deps do
    [
      {:uuid, "~> 1.1"},
      {:phoenix_pubsub, "~> 2.1"},
      {:ex_chat_dal, in_umbrella: true}
    ]
  end
end
