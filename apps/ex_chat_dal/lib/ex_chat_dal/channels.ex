defmodule ExChatDal.Channels do
  alias ExChatDal.{Repo, Channels.Channel}

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

  def delete_channel(%Channel{} = channel) do
    Repo.delete(channel)
  end

  def list_channels, do: Repo.all(Channel)

  def get_channel(id), do: Repo.get!(Channel, id)
end
