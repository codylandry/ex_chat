defmodule ExChatWeb.Live.App do
  use ExChatWeb, :live_view
  alias ExChatOtp.{ChannelServer, ChannelSupervisor}
  alias ExChatDal.{Channels, Accounts, Channels.Channel}
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    ExChatOtp.subscribe()
    channels = Channels.list_channels()
    socket = assign(socket, :channels, channels)

    if connected?(socket) do
      # Gives process a name in :observer
      Process.register(self(), :"user:#{socket.assigns.current_user.id}")
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    channel_id_str = Map.get(params, "channel_id")

    socket =
      if channel_id_str do
        channel_id = String.to_integer(channel_id_str)
        channel = ChannelServer.get_channel(channel_id)

        socket
        |> assign(:posts, channel.posts)
        |> assign(:members, channel.members)
        |> assign(:channel, channel)
      else
        socket
        |> assign(:channel, %Channel{})
        |> assign(:posts, [])
        |> assign(:members, [])
      end
      |> assign(
        :unjoined_channels,
        difference_by(socket.assigns.channels, socket.assigns.current_user.channels, & &1.id)
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("leave-channel", %{"channel_id" => channel_id}, socket) do
    ChannelServer.remove_member(channel_id, socket.assigns.current_user.id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("join-channel", %{"channel_id" => channel_id}, socket) do
    ChannelServer.add_member(channel_id, socket.assigns.current_user.id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("add-post", params, socket) do
    post = %{
      author_id: socket.assigns.current_user.id,
      content: params["content"]
    }

    ChannelServer.add_post(socket.assigns.channel.id, post)

    {:noreply, push_event(socket, "post-added", %{})}
  end

  @impl true
  def handle_event("remove-post", %{"post_id" => post_id}, socket) do
    ChannelServer.remove_post(socket.assigns.channel.id, String.to_integer(post_id))
    {:noreply, socket}
  end

  @impl true
  def handle_event("create-channel", %{"channel_name" => channel_name}, socket) do
    ChannelSupervisor.add_channel(channel_name, socket.assigns.current_user.id)
    {:noreply, socket}
  end

  @impl true
  def handle_info([event: :refresh, channel: channel, channel_id: channel_id], socket) do
    if channel_id == socket.assigns.channel.id do
      {:noreply, push_patch(socket, to: "/app/#{channel.id}")}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info([event: :member_added, member: member, channel_id: channel_id], socket) do
    members = [member | socket.assigns.channel.members]

    socket =
      if member.id == socket.assigns.current_user.id do
        socket
        |> update_channels(socket.assigns.channels)
        |> push_patch(to: "/app/#{channel_id}")
      else
        socket
      end
      |> assign(:current_user, Accounts.get_user!(socket.assigns.current_user.id))

    {:noreply, socket}
  end

  @impl true
  def handle_info([event: :member_removed, member_id: member_id, channel_id: channel_id], socket) do
    members = Enum.filter(socket.assigns.channel.members, fn m -> m.id != member_id end)

    currently_viewing_channel = channel_id == socket.assigns.channel.id
    is_current_user = member_id == socket.assigns.current_user.id

    socket =
      cond do
        currently_viewing_channel and is_current_user ->
          go_to_first_channel(socket)

        currently_viewing_channel ->
          assign(socket, :members, members)

        is_current_user ->
          socket
          |> assign(:current_user, Accounts.get_user!(socket.assigns.current_user.id))
          |> update_channels(socket.assigns.channels)

        true ->
          socket
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info(
        [event: :post_added, post: post, channel_id: channel_id, channel_name: channel_name],
        socket
      ) do
    if channel_id == socket.assigns.channel.id do
      posts =
        [post | socket.assigns.posts]
        |> Enum.dedup_by(fn p -> p.id end)

      socket =
        socket
        |> assign(:posts, posts)

      {:noreply, socket}
    else
      # a post from another channel
      if ChannelServer.is_member?(post.channel_id, socket.assigns.current_user.id) do
        {:noreply,
         put_flash(
           socket,
           :new_post,
           %{post: post, channel_name: channel_name}
         )}
      else
        {:noreply, socket}
      end
    end
  end

  @impl true
  def handle_info([event: :post_removed, post: post, channel_id: channel_id], socket) do
    posts = Enum.filter(socket.assigns.posts, fn m -> m.id != post.id end)

    socket =
      if channel_id == socket.assigns.channel.id do
        assign(socket, :posts, posts)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info([event: :channel_removed, channel_id: channel_id], socket) do
    socket =
      socket
      |> update_channels(Enum.filter(socket.assigns.channels, fn c -> c.id != channel_id end))

    {:noreply, socket}
  end

  @impl true
  def handle_info([event: :channel_added, channel: channel, creator_id: creator_id], socket) do
    socket =
      if creator_id do
        push_patch(socket, to: "/app/#{channel.id}")
      end
      |> update_channels([channel | socket.assigns.channels])

    {:noreply, socket}
  end

  def go_to_first_channel(socket) do
    first_channel = List.first(socket.assigns.channels)

    socket
    |> push_patch(to: "/app/#{first_channel.id}")
  end

  def update_channels(socket, new_channels) do
    socket
    |> assign(:channels, new_channels)
    |> assign(
      :unjoined_channels,
      difference_by(
        new_channels,
        socket.assigns.current_user.channels,
        & &1.id
      )
    )
  end
end
