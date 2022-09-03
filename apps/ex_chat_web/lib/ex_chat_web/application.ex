defmodule ExChatWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      {Cluster.Supervisor, [topologies, [name: ExChat.ClusterSupervisor]]},
      # Start the Telemetry supervisor
      ExChatWeb.Telemetry,
      # Start the Endpoint (http/https)
      ExChatWeb.Endpoint
      # Start a worker by calling: ExChatWeb.Worker.start_link(arg)
      # {ExChatWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExChatWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ExChatWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
