defmodule ExChatDal.Channels.Channel do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "channels" do
    field(:name, :string)

    many_to_many(:members, ExChatDal.Accounts.User,
      join_through: ExChatDal.Channels.ChannelMember,
      join_keys: [channel_id: :id, member_id: :id]
    )

    has_many(:posts, ExChatDal.Posts.Post)

    timestamps()
  end

  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name])
    |> validate_name()
  end

  def validate_name(changeset) do
    changeset
    |> validate_required([:name])
    |> validate_length(:name, min: 2, max: 20)
  end

  @doc """
  Adds user to channel members list
  ## Examples:
      # setup
      iex> alias ExChatOtp.{Channel, User}
      iex> user1 = User.new(id: 1, email: "bob-fake@email.com", username: "bob")
      iex> user2 = User.new(id: 2, email: "tom-fake@email.com", username: "tom")
      iex> channel = Channel.new(id: 1, name: "test", members: [user1])
      iex> channel.members
      [user1]
      # example
      iex> channel = Channel.add_member(channel, user2)
      iex> channel.members
      [user2, user1]
      # Does not add duplicate users as members
      iex> channel = Channel.add_member(channel, user2)
      iex> channel.members
      [user2, user1]
  """
  def add_member(channel, user) do
    if is_member?(channel, user.id) do
      channel
    else
      Map.put(channel, :members, [user | channel.members])
    end
  end

  @doc """
  Removes member with id == user_id
  ## Examples
      # setup
      iex> alias ExChatOtp.{Channel, User}
      iex> user1 = User.new(id: 1, email: "bob-fake@email.com", username: "bob")
      iex> user2 = User.new(id: 2, email: "tom-fake@email.com", username: "tom")
      iex> channel = Channel.new(id: 1, name: "test", members: [user2, user1])
      iex> channel.members
      [user2, user1]
      # example
      iex> channel = Channel.remove_member(channel, user2.id)
      iex> channel.members
      [user1]
      iex> # Does nothing if user not a member
      iex> channel = Channel.remove_member(channel, user2.id)
      iex> channel.members
      [user1]
  """
  def remove_member(channel, user_id) do
    members = Enum.filter(channel.members, fn u -> u.id != user_id end)
    Map.put(channel, :members, members)
  end

  @doc """
  Returns true if user with user_id exists in the channel members list

  ## Examples:
      # setup
      iex> alias ExChatOtp.{Channel, User}
      iex> user1 = User.new(id: 1, email: "bob-fake@email.com", username: "bob")
      iex> user2 = User.new(id: 2, email: "tom-fake@email.com", username: "tom")
      iex> channel = Channel.new(id: 1, name: "test", members: [user1])
      iex> channel.members
      [user1]
      # example
      iex> Channel.is_member?(channel, user1.id)
      true
      iex> Channel.is_member?(channel, user2.id)
      false
  """
  def is_member?(channel, user_id) do
    is_member =
      channel.members
      |> Enum.find_value(fn member -> member.id == user_id end)

    !!is_member
  end

  @doc """
  Adds a post to channel posts list
  ## Examples
      # setup
      iex> alias ExChatOtp.{Channel, User, Post}
      iex> user1 = User.new(id: 1, email: "bob-fake@email.com", username: "bob")
      iex> channel = Channel.new(id: 1, name: "test", members: [user1])
      iex> channel.posts
      []
      # example
      iex> post = Post.new(id: 1, channel_id: channel.id, user: user1, content: "test post")
      iex> channel = Channel.add_post(channel, post)
      iex> channel.posts
      [post]
      # posts are deduped by :id
      iex> post = Post.new(id: 1, channel_id: channel.id, user: user1, content: "test post")
      iex> channel = Channel.add_post(channel, post)
      iex> channel.posts
      [post]
  """
  def add_post(%Channel{} = channel, post) do
    post = Map.put(post, :channel_id, channel.id)
    Map.put(channel, :posts, [post | channel.posts])
  end

  @doc """
  Removes post with id == post_id from channel posts list
  ## Examples
      # setup
      iex> alias ExChatOtp.{Channel, User, Post}
      iex> user1 = User.new(id: 1, email: "bob-fake@email.com", username: "bob")
      iex> channel = Channel.new(id: 1, name: "test", members: [user1])
      iex> channel.posts
      []
      iex> post1 = Post.new(id: 1, channel_id: channel.id, user: user1, content: "test post 1")
      iex> post2 = Post.new(id: 2, channel_id: channel.id, user: user1, content: "test post 2")
      iex> channel = Channel.add_post(channel, post1)
      iex> channel = Channel.add_post(channel, post2)
      iex> channel.posts
      [post2, post1]
      # example
      iex> channel = Channel.remove_post(channel, post2.id)
      iex> channel.posts
      [post1]
  """
  def remove_post(channel, post_id) do
    posts = Enum.filter(channel.posts, fn u -> u.id != post_id end)
    Map.put(channel, :posts, posts)
  end
end
