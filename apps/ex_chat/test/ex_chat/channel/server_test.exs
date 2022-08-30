defmodule ExChatChannelServerTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureLog
  alias ExChat.{ChannelServer, Channel, User, Post}

  def random_id, do: Enum.random(0..10000)

  setup do
    channel = Channel.new(id: random_id(), name: "my-channel")
    {:ok, pid} = ChannelServer.start_link(channel)

    on_exit(fn ->
      Process.exit(pid, :kill)
    end)

    %{pid: pid, channel: channel}
  end

  describe "get_channel/1" do
    test "should get channel struct", context do
      assert context.channel == ChannelServer.get_channel(context.channel.id)
    end
  end

  describe "via_tuple/1" do
    test "reliably identifies process", context do
      [{returned_pid, _}] =
        Registry.lookup(
          ExChat.ChannelRegistry,
          ChannelServer.channel_name(context.channel.id)
        )

      assert context.pid == returned_pid
    end
  end

  describe "add_member/2" do
    test "adds member to channel members list", context do
      user = User.new(id: random_id(), email: "bob-fake@email.com", username: "bob")
      ChannelServer.add_member(context.channel.id, user)
      assert ChannelServer.get_channel(context.channel.id).members == [user]
    end

    test "dedupes members by id", context do
      random_id = random_id()
      user1 = User.new(id: random_id, email: "bob-fake@email.com", username: "bob")
      user2 = User.new(id: random_id, email: "tom-fake@email.com", username: "tom")
      ChannelServer.add_member(context.channel.id, user1)
      ChannelServer.add_member(context.channel.id, user2)
      assert ChannelServer.get_channel(context.channel.id).members == [user1]
    end
  end

  describe "remove_member/2" do
    test "removes member from channel members list", context do
      user1 = User.new(id: random_id(), email: "bob-fake@email.com", username: "bob")
      user2 = User.new(id: random_id(), email: "tom-fake@email.com", username: "tom")
      ChannelServer.add_member(context.channel.id, user1)
      ChannelServer.add_member(context.channel.id, user2)
      assert ChannelServer.get_channel(context.channel.id).members == [user2, user1]
      ChannelServer.remove_member(context.channel.id, user2.id)
      assert ChannelServer.get_channel(context.channel.id).members == [user1]
    end

    test "ignores when member not in list", context do
      user1 = User.new(id: random_id(), email: "bob-fake@email.com", username: "bob")
      user2 = User.new(id: random_id(), email: "tom-fake@email.com", username: "tom")
      ChannelServer.add_member(context.channel.id, user1)
      assert ChannelServer.get_channel(context.channel.id).members == [user1]
      ChannelServer.remove_member(context.channel.id, user2.id)
      assert ChannelServer.get_channel(context.channel.id).members == [user1]
    end
  end

  describe "is_member?/2" do
    test "returns whether a user with user_id is in the channel members list", context do
      user1 = User.new(id: random_id(), email: "bob-fake@email.com", username: "bob")
      user2 = User.new(id: random_id(), email: "tom-fake@email.com", username: "tom")
      ChannelServer.add_member(context.channel.id, user1)
      assert ChannelServer.get_channel(context.channel.id).members == [user1]
      assert ChannelServer.is_member?(context.channel.id, user1.id)
      refute ChannelServer.is_member?(context.channel.id, user2.id)
    end
  end

  describe "add_post/2" do
    test "adds post to channel posts list", context do
      user1 = User.new(id: random_id(), email: "bob-fake@email.com", username: "bob")

      post =
        Post.new(
          id: random_id(),
          channel_id: context.channel.id,
          user: user1,
          content: "some post content"
        )

      ChannelServer.add_post(context.channel.id, post)
      assert ChannelServer.get_channel(context.channel.id).posts == [post]
    end

    test "should not add posts with a different channel id", context do
      user1 = User.new(id: random_id(), email: "bob-fake@email.com", username: "bob")

      post =
        Post.new(
          id: random_id(),
          channel_id: 9999,
          user: user1,
          content: "some post content"
        )

      # we should be logging something if this happens
      assert capture_log([level: :error], fn ->
               ChannelServer.add_post(context.channel.id, post)
               assert ChannelServer.get_channel(context.channel.id).posts == []
             end) =~ "[error] attempted to add post"
    end
  end

  describe "remove_post/2" do
    test "removes post from channel post list when exists", context do
      user1 = User.new(id: random_id(), email: "bob-fake@email.com", email: "bob-fake@email.com", username: "bob")

      post1 =
        Post.new(
          id: random_id(),
          channel_id: context.channel.id,
          user: user1,
          content: "post content 1"
        )

      post2 =
        Post.new(
          id: random_id(),
          channel_id: context.channel.id,
          user: user1,
          content: "post content 2"
        )

      ChannelServer.add_post(context.channel.id, post1)
      ChannelServer.add_post(context.channel.id, post2)
      ChannelServer.remove_post(context.channel.id, post2.id)
      assert ChannelServer.get_channel(context.channel.id).posts == [post1]
    end

    test "does nothing when no post with id == post_id in channel posts list", context do
      user1 = User.new(id: random_id(), email: "bob-fake@email.com", username: "bob")

      post1 =
        Post.new(
          id: random_id(),
          channel_id: context.channel.id,
          user: user1,
          content: "post content 1"
        )

      post2 =
        Post.new(
          id: random_id(),
          channel_id: context.channel.id,
          user: user1,
          content: "post content 2"
        )

      ChannelServer.add_post(context.channel.id, post1)
      ChannelServer.remove_post(context.channel.id, post2.id)
      assert ChannelServer.get_channel(context.channel.id).posts == [post1]
    end
  end
end
