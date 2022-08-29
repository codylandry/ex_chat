defmodule ExChat do
#  alias ExChat.{Channel}

#  @doc """
#  Uses or creates a channel along with a channel process
#  Examples:
#    iex> alias ExChat.Channel
#    iex> {:ok, _pid, %Channel{} = _channel} = ExChat.channel("my new channel")
#    iex> channel = Channel.new("another channel")
#    iex> {:ok, _pid, %Channel{} = _channel} = ExChat.channel(channel)
#  """
#  def channel(id, name) when is_integer(id) and is_binary(name) do
#    channel = Channel.new(id: id, name: name)
#    {:ok, pid} = Channel.Supervisor.add_channel(channel)
#    {:ok, pid, channel}
#  end
#
#  def channel(%Channel{} = channel) do
#    {:ok, pid} = Channel.Supervisor.add_channel(channel)
#    {:ok, pid, channel}
#  end
end
