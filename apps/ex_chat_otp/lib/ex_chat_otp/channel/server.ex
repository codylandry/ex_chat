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

  @impl true
  def init(channel_id) when is_integer(channel_id) do
    Logger.info("Starting #{channel_id}")
    channel = Channels.get_channel(channel_id)
    state = %{channel: channel}

    {:ok, state}
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
    GenServer.cast(via_tuple(channel_id), {:member_added, user_id})
  end

  def remove_member(channel_id, user_id) do
    GenServer.cast(via_tuple(channel_id), {:member_removed, user_id})
  end

  def is_member?(channel_id, user_id) do
    GenServer.call(via_tuple(channel_id), {:is_member, user_id})
  end

  def add_post(channel_id, post) do
    GenServer.cast(via_tuple(channel_id), {:post_added, post})
  end

  def remove_post(channel_id, post_id) do
    GenServer.cast(via_tuple(channel_id), {:post_removed, post_id})
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

    ExChatOtp.broadcast_event(
      event: :refresh,
      channel: state.channel,
      channel_id: state.channel.id
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast({:member_added, user_id}, state) do
    attempt_async(state, fn ->
      Channels.add_member(state.channel.id, user_id)
    end)

    user = Accounts.get_user!(user_id)
    state = %{state | channel: Channel.add_member(state.channel, user)}

    ExChatOtp.broadcast_event(
      event: :member_added,
      member: user,
      channel_id: state.channel.id
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast({:member_removed, user_id}, state) do
    member = Enum.find(state.channel.members, fn m -> m.id == user_id end)

    attempt_async(state, fn ->
      Channels.remove_member(state.channel.id, user_id)
    end)

    state = %{state | channel: Channel.remove_member(state.channel, user_id)}

    ExChatOtp.broadcast_event(
      event: :member_removed,
      channel_id: state.channel.id,
      member: member
    )

    {:noreply, state}
  end

  @impl true
  def handle_cast({:post_added, post_attrs}, state) do
    post_attrs = Map.put(post_attrs, :channel_id, state.channel.id)

    post = Posts.create_post(state.channel.id, post_attrs)

    # broadcast_channel_event(state.channel.id,
    #   event: :post_added,
    #   post: post
    # )

    ExChatOtp.broadcast_event(
      event: :post_added,
      post: post,
      channel_id: state.channel.id
    )

    channel = Channel.add_post(state.channel, post)
    state = %{state | channel: channel}

    {:noreply, state}
  end

  @impl true
  def handle_cast({:post_removed, post_id}, state) do
    post = Enum.find(state.channel.posts, fn p -> p.id == post_id end)

    IO.inspect(post, label: "post")

    attempt_async(state, fn ->
      Posts.delete_post(post_id)
    end)

    channel = Channel.remove_post(state.channel, post_id)
    state = %{state | channel: channel}

    # broadcast_channel_event(state.channel.id,
    #   event: :post_removed,
    #   post: post
    # )

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
