defmodule ExChatWeb.Live.App do
  use ExChatWeb, :live_view
  alias ExChatOtp.{ChannelServer, ChannelSupervisor}
  alias ExChatDal.Channels
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    ExChatOtp.subscribe()
    channels = Channels.list_channels()
    socket = assign(socket, :channels, channels)

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    current_channel_id = Map.get(socket.assigns, :channel_id)

    if current_channel_id do
      ChannelServer.unsubscribe(current_channel_id)
    end

    channel_id_str = Map.get(params, "channel_id")

    socket =
      if channel_id_str do
        channel_id = String.to_integer(channel_id_str)
        ChannelServer.subscribe(channel_id)
        channel = ChannelServer.get_channel(channel_id)

        assign(socket, :channel, channel)
      else
        socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("leave-channel", _params, socket) do
    ChannelServer.remove_member(socket.assigns.channel.id, socket.assigns.current_user.id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("join-channel", _params, socket) do
    ChannelServer.add_member(socket.assigns.channel.id, socket.assigns.current_user.id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("add-post", params, socket) do
    post = %{
      author_id: socket.assigns.current_user.id,
      content: params["content"]
    }

    ChannelServer.add_post(socket.assigns.channel.id, post)

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove-post", %{"post_id" => post_id}, socket) do
    ChannelServer.remove_post(socket.assigns.channel.id, String.to_integer(post_id))
    {:noreply, socket}
  end

  @impl true
  def handle_event("create-channel", %{"channel_name" => channel_name}, socket) do
    channel = ChannelSupervisor.add_channel(channel_name)
    socket = assign(socket, :channels, [channel | socket.assigns.channels])
    {:noreply, socket}
  end

  @impl true
  def handle_info([event: :refresh, channel: channel], socket) do
    {:noreply, push_patch(socket, to: "/app/#{channel.id}")}
  end

  @impl true
  def handle_info([event: :add_member, member: member], socket) do
    members = [member | socket.assigns.channel.members]
    channel = Map.put(socket.assigns.channel, :members, members)
    socket = assign(socket, :channel, channel)
    {:noreply, socket}
  end

  @impl true
  def handle_info([event: :remove_member, member: member], socket) do
    members = Enum.filter(socket.assigns.channel.members, fn m -> m.id != member.id end)
    channel = Map.put(socket.assigns.channel, :members, members)
    socket = assign(socket, :channel, channel)
    {:noreply, socket}
  end

  @impl true
  def handle_info([event: :add_post, post: post], socket) do
    if post.channel_id == socket.assigns.channel.id do
      posts =
        [post | socket.assigns.channel.posts]
        |> Enum.dedup_by(fn p -> p.id end)

      channel = Map.put(socket.assigns.channel, :posts, posts)
      socket = assign(socket, :channel, channel)
      {:noreply, socket}
    else
      IO.inspect(post, label: "post from another page")

      {:noreply,
       put_flash(
         socket,
         :info,
         "#{post.author.email} sent a new message in #{post.channel.name}<br>#{post.content}"
       )}
    end
  end

  @impl true
  def handle_info([event: :remove_post, post: post], socket) do
    posts = Enum.filter(socket.assigns.channel.posts, fn m -> m.id != post.id end)
    channel = Map.put(socket.assigns.channel, :posts, posts)
    socket = assign(socket, :channel, channel)
    {:noreply, socket}
  end

  @impl true
  def handle_info([event: :channel_removed, channel_id: channel_id], socket) do
    socket =
      assign(
        socket,
        :channels,
        Enum.filter(socket.assigns.channels, fn c -> c.id != channel_id end)
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info([event: :channel_added, channel: channel], socket) do
    socket =
      assign(
        socket,
        :channels,
        [channel | socket.assigns.channels]
      )

    {:noreply, socket}
  end
end
