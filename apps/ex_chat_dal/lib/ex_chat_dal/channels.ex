defmodule ExChatDal.Channels do
  import Ecto.Query
  alias ExChatDal.{Repo, Channels.Channel, Channels.ChannelMember, Accounts.User}

  @doc """
  Creates a channel struct, validates and inserts into db if valid
  ## Examples
      iex> {:ok, %Channel{} = channel} = create_channel(%{name: "test-channel"})
      iex> assert channel.name == "test-channel"
  """
  def create_channel(attrs) do
    %Channel{}
    |> Channel.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a channel struct, validates and updates it in db if valid
  ## Examples
      iex> {:ok, %Channel{} = channel} = create_channel(%{name: "test-channel-1"})
      iex> {:ok, %Channel{} = channel} = update_channel(channel, %{name: "test-channel-2"})
      iex> assert channel.name == "test-channel-2"
  """
  def update_channel(%Channel{} = channel, attrs) do
    channel
    |> Channel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Adds a User struct to channel members list and updates db
  ## Examples
      iex> {:ok, user} = Accounts.register_user(%{email: "fake@email.com", username: "fake", password: "password"})
      iex> {:ok, %Channel{} = channel} = create_channel(%{name: "test-channel"})
      iex> add_member(channel.id, user.id)
      iex> list_members_by_channel_id(channel.id)
      [user]
  """
  def add_member(channel_id, user_id) do
    %ChannelMember{}
    |> ChannelMember.changeset(%{channel_id: channel_id, member_id: user_id})
    |> Repo.insert()
  end

  @doc """
  Removes a User struct from channel members list and updates db
  ## Examples
      iex> {:ok, user} = Accounts.register_user(%{email: "fake@email.com", username: "fake", password: "password"})
      iex> {:ok, %Channel{} = channel} = create_channel(%{name: "test-channel"})
      iex> add_member(channel.id, user.id)
      iex> list_members_by_channel_id(channel.id)
      [user]
  """
  def remove_member(channel_id, user_id) do
    from(cm in ChannelMember, where: cm.channel_id == ^channel_id and cm.member_id == ^user_id)
    |> Repo.delete_all()
  end

  @doc """
  Returns all member User structs for channel
  ## Examples
      iex> {:ok, user} = Accounts.register_user(%{email: "fake@email.com", username: "fake", password: "password"})
      iex> {:ok, %Channel{} = channel} = create_channel(%{name: "test-channel"})
      iex> add_member(channel.id, user.id)
      iex> list_members_by_channel_id(channel.id)
      [user]
  """
  def list_members_by_channel_id(channel_id) do
    from(
      m in ChannelMember,
      join: u in User,
      on: m.member_id == u.id,
      where: m.channel_id == ^channel_id,
      select: u
    )
    |> Repo.all()
  end

  @doc """
  Deletes a channel from the db
  ## Examples
      iex> {:ok, %Channel{} = channel} = create_channel(%{name: "test-channel"})
      iex> delete_channel(channel)
      iex> assert_raise Ecto.NoResultsError, fn -> get_channel(channel.id) end
  """
  def delete_channel(channel_id) do
    from(c in Channel, where: c.id == ^channel_id)
    |> Repo.delete_all()
  end

  @doc """
  Returns all member User structs for channel
  ## Examples
      iex> {:ok, c1} = create_channel(%{name: "test-channel-1"})
      iex> {:ok, c2} = create_channel(%{name: "test-channel-2"})
      iex> {:ok, c3} = create_channel(%{name: "test-channel-3"})
      iex> list_channels()
      [c1, c2, c3]
  """
  def list_channels, do: Repo.all(Channel)

  @doc """
  Returns channel by id
  ## Examples
      iex> {:ok, c1} = create_channel(%{name: "test-channel-1"})
      iex> get_channel(c1.id)
      c1
  """
  def get_channel(channel_id) do
    from(
      channel in Channel,
      left_join: posts in assoc(channel, :posts),
      left_join: members in assoc(channel, :members),
      left_join: authors in assoc(posts, :author),
      where: channel.id == ^channel_id,
      preload: [posts: {posts, author: authors}, members: members]
    )
    |> Repo.one!()
  end
end
