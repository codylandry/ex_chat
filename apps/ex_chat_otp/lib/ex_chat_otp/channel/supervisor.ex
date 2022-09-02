defmodule ExChatOtp.ChannelSupervisor do
  use DynamicSupervisor
  alias ExChatOtp.ChannelServer
  alias ExChatDal.Channels

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_channel(channel_arg, creator_id \\ nil)

  # Start a Player process and add it to supervision
  def add_channel(channel_id, creator_id) when is_integer(channel_id) do
    DynamicSupervisor.start_child(__MODULE__, ChannelServer.child_spec(channel_id, creator_id))
  end

  def add_channel(channel_name, creator_id) when is_binary(channel_name) do
    {:ok, channel} = Channels.create_channel(%{name: channel_name})
    add_channel(channel.id, creator_id)
  end

  # Terminate a Player process and remove it from supervision
  def remove_channel(channel_id) do
    DynamicSupervisor.terminate_child(__MODULE__, ChannelServer.channel_name(channel_id))
    Channels.delete_channel(channel_id)
    ExChatOtp.broadcast_event(event: :channel_removed, channel_id: channel_id)
  end

  # Nice utility method to check which processes are under supervision
  def children do
    DynamicSupervisor.which_children(__MODULE__)
  end

  # Nice utility method to check which processes are under supervision
  def count_children do
    DynamicSupervisor.count_children(__MODULE__)
  end
end
