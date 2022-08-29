defmodule ExChatDal.Channels.ChannelMember do
  use Ecto.Schema
  import Ecto.Changeset
  alias __MODULE__

  schema "channel_members" do
    belongs_to(:member, ExChatDal.Accounts.User)
    belongs_to(:channel, ExChatDal.Channels.Channel)
  end

  def changeset(%ChannelMember{} = channel_member, attrs) do
    channel_member
    |> cast(attrs, [:member_id, :channel_id])
    |> validate_required([:member_id, :channel_id])
    |> assoc_constraint(:channel)
    |> assoc_constraint(:member)
  end
end
