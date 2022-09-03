defmodule ExChatOtp.Application do
  @moduledoc """
  Supervises both the channel process registry and channel dynamic supervisor
  """

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      {Cluster.Supervisor, [topologies, [name: ExChatOtp.ClusterSupervisor]]},
      {Phoenix.PubSub, name: ExChatOtp.PubSub},
      {Registry, keys: :unique, name: ExChatOtp.ChannelRegistry},
      ExChatOtp.ChannelSupervisor,
      ExChatOtp.InitializationTask
    ]

    opts = [strategy: :one_for_one, name: ExChatOtp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
