defmodule ExChatDal.Channels do
  import Ecto.Query
  alias ExChatDal.{Repo, Channels.Channel, Channels.ChannelMember, Accounts.User}

  def create_channel(attrs) do
    %Channel{}
    |> Channel.changeset(attrs)
    |> Repo.insert()
  end

  def update_channel(%Channel{} = channel, attrs) do
    channel
    |> Channel.changeset(attrs)
    |> Repo.update()
  end

  def add_member(channel_id, user_id) do
    %ChannelMember{}
    |> ChannelMember.changeset(%{channel_id: channel_id, member_id: user_id})
    |> Repo.insert()
  end

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

  def delete_channel(%Channel{} = channel) do
    Repo.delete(channel)
  end

  def list_channels, do: Repo.all(Channel)

  def get_channel(id), do: Repo.get!(Channel, id)
end
