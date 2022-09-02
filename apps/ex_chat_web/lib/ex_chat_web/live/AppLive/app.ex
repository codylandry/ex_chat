defmodule ExChatWeb.Live.App do
  use ExChatWeb, :live_view
  alias ExChatOtp.{ChannelServer, ChannelSupervisor}
  alias ExChatDal.{Channels, Accounts}
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

        socket
        |> assign(:posts, channel.posts)
        |> assign(:members, channel.members)
        |> assign(:channel, channel)
        |> assign(
          :unjoined_channels,
          difference_by(socket.assigns.channels, socket.assigns.current_user.channels, & &1.id)
        )
      else
        socket
      end

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
    channel = ChannelSupervisor.add_channel(channel_name)

    socket =
      socket
      |> push_patch(to: "/app/#{channel.id}")

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
      if channel_id == socket.channel.id do
        socket
        |> assign(:members, members)

        # |> assign_channel(:members, members)
      else
        socket
      end
      |> assign(:current_user, Accounts.get_user!(socket.current_user.id))

    {:noreply, socket}
  end

  @impl true
  def handle_info([event: :member_removed, member: member, channel_id: channel_id], socket) do
    members = Enum.filter(socket.assigns.channel.members, fn m -> m.id != member.id end)

    socket =
      if channel_id == socket.channel.id do
        socket
        |> assign(:members, members)

        # |> assign_channel(:members, members)
      else
        socket
      end
      |> assign(:current_user, Accounts.get_user!(socket.current_user.id))

    {:noreply, socket}
  end

  @impl true
  def handle_info([event: :post_added, post: post, channel_id: channel_id], socket) do
    if channel_id == socket.assigns.channel.id do
      posts =
        [post | socket.assigns.channel.posts]
        |> Enum.dedup_by(fn p -> p.id end)

      socket =
        socket
        |> assign(:posts, posts)

      # |> assign_channel(:posts, posts)

      {:noreply, socket}
    else
      # a post from another channel
      if ChannelServer.is_member?(post.channel_id, socket.assigns.current_user.id) do
        channel = ChannelServer.get_channel(post.channel_id)

        {:noreply,
         put_flash(
           socket,
           :new_post,
           %{post: post, channel: channel}
         )}
      end
    end
  end

  @impl true
  def handle_info([event: :post_removed, post: post, channel_id: channel_id], socket) do
    posts = Enum.filter(socket.assigns.channel.posts, fn m -> m.id != post.id end)

    socket =
      if channel_id == socket.channel.id do
        socket
        |> assign(:posts, posts)

        # |> assign_channel(:posts, posts)
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
  def handle_info([event: :channel_added, channel: channel], socket) do
    socket =
      socket
      |> update_channels([channel | socket.assigns.channels])

    {:noreply, socket}
  end

  # defp assign_channel(socket, prop, value) do
  #   channel = Map.put(socket.assigns.channel, prop, value)
  #   assign(socket, :channel, channel)
  # end

  def update_channels(socket, new_channels) do
    socket
    |> assign(:channels, new_channels)
    |> assign(
      :unjoined_channels,
      difference_by(
        socket.assigns.channels,
        socket.assigns.current_user.channels,
        & &1.id
      )
    )
  end
end
