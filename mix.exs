defmodule ExChat.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    []
  end

  def releases,
    do: [
      ex_chat: [
        applications: [ex_chat_web: :permanent, ex_chat_otp: :permanent],
        cookie: System.get_env("ERL_COOKIE")
      ]
    ]
end
