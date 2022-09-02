defmodule ExChatOtp.ChannelServer do
  @moduledoc """
  Manages state for a chat channel.
  Tracks relevant state such as members and posts.
  """

  use GenServer

  alias ExChatDal.{
    Channels,
    Channels.Channel,
    Accounts,
    Posts
  }

  require Logger

  def start_link(channel_id) when is_integer(channel_id) do
    GenServer.start_link(__MODULE__, channel_id, name: via_tuple(channel_id))
  end

  def via_tuple(channel_id),
    do: {:via, Registry, {ExChatOtp.ChannelRegistry, channel_name(channel_id)}}

  def channel_name(channel_id), do: "channel:#{channel_id}"

  def child_spec(channel_id) do
    %{
      id: channel_name(channel_id),
      start: {__MODULE__, :start_link, [channel_id]},
      restart: :transient
    }
  end

  defp broadcast_channel_event(channel_id, event) do
    :ok = Phoenix.PubSub.broadcast(ExChatOtp.PubSub, channel_name(channel_id), event)
  end

  def subscribe(channel_id) do
    :ok = Phoenix.PubSub.subscribe(ExChatOtp.PubSub, channel_name(channel_id))
  end

  def unsubscribe(channel_id) do
    :ok = Phoenix.PubSub.unsubscribe(ExChatOtp.PubSub, channel_name(channel_id))
  end

  defp attempt_async(state, func) do
    Task.start(fn ->
      try do
        func.()
      rescue
        e ->
          Logger.error(e)
          refresh_state(state.channel.id)
      end
    end)
  end

  def get_channel(channel_id) do
    GenServer.call(via_tuple(channel_id), :get_channel)
  end

  def add_member(channel_id, user_id) do
    GenServer.cast(via_tuple(channel_id), {:add_member, user_id})
  end

  def remove_member(channel_id, user_id) do
    GenServer.cast(via_tuple(channel_id), {:remove_member, user_id})
  end

  def is_member?(channel_id, user_id) do
    GenServer.call(via_tuple(channel_id), {:is_member, user_id})
  end

  def add_post(channel_id, post) do
    GenServer.cast(via_tuple(channel_id), {:add_post, post})
  end

  def remove_post(channel_id, post_id) do
    GenServer.cast(via_tuple(channel_id), {:remove_post, post_id})
  end

  def refresh_state(channel_id) do
    GenServer.cast(via_tuple(channel_id), :refresh_state)
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

  # Callbacks

  @impl true
  def init(channel_id) when is_integer(channel_id) do
    Logger.info("Starting #{channel_id}")
    channel = Channels.get_channel(channel_id)
    state = %{channel: channel}

    {:ok, state}
  end

  @impl true
  def handle_call({:is_member, user_id}, _from, state) do
    {:reply, Channel.is_member?(state.channel, user_id), state}
  end

  @impl true
  def handle_call(:get_channel, _from, state) do
    {:reply, state.channel, state}
  end

  def handle_cast(:refresh_state, state) do
    channel = Channels.get_channel(state.channel.id)
    state = %{channel: channel}

    broadcast_channel_event(state.channel.id,
      event: :refresh,
      channel: state.channel
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast({:add_member, user_id}, state) do
    attempt_async(state, fn ->
      Channels.add_member(state.channel.id, user_id)
    end)

    user = Accounts.get_user!(user_id)
    state = %{state | channel: Channel.add_member(state.channel, user)}

    broadcast_channel_event(state.channel.id,
      event: :add_member,
      member: user
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast({:remove_member, user_id}, state) do
    member = Enum.find(state.channel.members, fn m -> m.id == user_id end)

    attempt_async(state, fn ->
      Channels.remove_member(state.channel.id, user_id)
    end)

    state = %{state | channel: Channel.remove_member(state.channel, user_id)}

    broadcast_channel_event(state.channel.id,
      event: :remove_member,
      member: member
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast({:add_post, post_attrs}, state) do
    post_attrs = Map.put(post_attrs, :channel_id, state.channel.id)

    post = Posts.create_post(state.channel.id, post_attrs)

    broadcast_channel_event(state.channel.id,
      event: :add_post,
      post: post
    )

    ExChatOtp.broadcast_event(
      event: :add_post,
      post: post
    )

    channel = Channel.add_post(state.channel, post)
    state = %{state | channel: channel}

    {:noreply, state}
  end

  @impl true
  def handle_cast({:remove_post, post_id}, state) do
    post = Enum.find(state.channel.posts, fn p -> p.id == post_id end)

    IO.inspect(post, label: "post")

    attempt_async(state, fn ->
      Posts.delete_post(post_id)
    end)

    channel = Channel.remove_post(state.channel, post_id)
    state = %{state | channel: channel}

    broadcast_channel_event(state.channel.id,
      event: :remove_post,
      post: post
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast(:raise, name),
    do: raise(RuntimeError, message: "Error, Server #{name} has crashed")

  @impl true
  def terminate(reason, state) do
    Logger.info("Exiting worker: #{state.channel.id} with reason: #{inspect(reason)}")
  end
end
