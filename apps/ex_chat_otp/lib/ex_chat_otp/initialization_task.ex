defmodule ExChatOtp.InitializationTask do
  use Task, restart: :transient

  alias ExChatDal.Channels

  def start_link(_arg) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run do
    Channels.list_channels()
    |> Enum.each(&ExChatOtp.ChannelSupervisor.add_channel(&1.id))
  end
end
