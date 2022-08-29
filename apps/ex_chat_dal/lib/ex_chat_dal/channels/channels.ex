defmodule ExChatDal.Channels.Channel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "channels" do
    field :name, :string
    many_to_many :members, ExChatDal.Accounts.User, join_through: ExChatDal.Channels.ChannelMember

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
end
