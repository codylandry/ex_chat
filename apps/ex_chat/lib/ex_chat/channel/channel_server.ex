defmodule ExChat.ChannelServer do
  @moduledoc """
  Manages state for a chat channel.
  Tracks relevant state such as members and posts.
  """

  use GenServer
  alias ExChat.{Channel, User, Post}
  require Logger

  def start_link(%Channel{} = channel) do
    GenServer.start_link(__MODULE__, channel, name: via_tuple(channel.id))
  end

  def via_tuple(channel_id),
    do: {:via, Registry, {ExChat.ChannelRegistry, channel_name(channel_id)}}

  def channel_name(channel_id), do: "channel:#{channel_id}"

  def child_spec(channel) do
    %{
      id: channel_name(channel.id),
      start: {__MODULE__, :start_link, [channel]},
      restart: :transient
    }
  end

  @doc """
  Gracefully stops channel process
  """
  def stop(channel_id), do: GenServer.stop(via_tuple(channel_id))

  @doc """
  Crashes the channel process
  For demonstration purposes only.
  """
  def crash(channel_id), do: GenServer.cast(via_tuple(channel_id), :raise)

  def get_channel(channel_id) do
    GenServer.call(via_tuple(channel_id), :get_channel)
  end

  def add_member(channel_id, user) do
    GenServer.cast(via_tuple(channel_id), {:add_member, user})
  end

  def remove_member(channel_id, user_id) do
    GenServer.cast(via_tuple(channel_id), {:remove_member, user_id})
  end

  def is_member?(channel_id, user_id) do
    GenServer.call(via_tuple(channel_id), {:is_member, user_id})
  end

  def add_post(channel_id, %Post{} = post) do
    GenServer.cast(via_tuple(channel_id), {:add_post, post})
  end

  def remove_post(channel_id, post_id) do
    GenServer.cast(via_tuple(channel_id), {:remove_post, post_id})
  end

  # Callbacks

  @impl true
  def init(%Channel{} = channel) do
    Logger.info("Starting #{channel.id}")
    {:ok, channel}
  end

  @impl true
  def handle_call({:is_member, user_id}, _from, channel) do
    {:reply, Channel.is_member?(channel, user_id), channel}
  end

  @impl true
  def handle_call(:get_channel, _from, channel) do
    {:reply, channel, channel}
  end

  @impl true
  def handle_cast({:add_member, %User{} = user}, channel) do
    {:noreply, Channel.add_member(channel, user)}
  end

  @impl true
  def handle_cast({:remove_member, user_id}, channel) do
    {:noreply, Channel.remove_member(channel, user_id)}
  end

  @impl true
  def handle_cast({:add_post, post}, channel) do
    channel =
      try do
        Channel.add_post(channel, post)
      rescue
        # Channel.add_post requires that channel.id and post.id match to ensure no strange data inconsistencies
        _e in FunctionClauseError ->
          Logger.error(
            "attempted to add post [#{post.id}] with channel [#{post.channel_id}] to channel [#{channel.id}]"
          )

          channel
      end

    {:noreply, channel}
  end

  @impl true
  def handle_cast({:remove_post, post_id}, channel) do
    {:noreply, Channel.remove_post(channel, post_id)}
  end

  @impl true
  def handle_cast(:raise, name),
    do: raise(RuntimeError, message: "Error, Server #{name} has crashed")

  @impl true
  def terminate(reason, channel) do
    Logger.info("Exiting worker: #{channel.id} with reason: #{inspect(reason)}")
  end
end
