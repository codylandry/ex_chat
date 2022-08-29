defmodule ExChat.Application do
  @moduledoc """
  Supervises both the channel process registry and channel dynamic supervisor
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # maps channel_id to its managing process
      {Registry, keys: :unique, name: ExChat.ChannelRegistry},

      # Supervises all channel servers
      ExChat.ChannelSupervisor
    ]

    opts = [strategy: :one_for_one, name: ExChat.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
