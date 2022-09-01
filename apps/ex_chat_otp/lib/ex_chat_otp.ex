defmodule ExChatOtp do
  def pubsub_topic, do: "ex_chat_otp"

  def broadcast_event(event) do
    :ok = Phoenix.PubSub.broadcast(ExChatOtp.PubSub, pubsub_topic, event)
  end

  def subscribe() do
    :ok = Phoenix.PubSub.subscribe(ExChatOtp.PubSub, pubsub_topic)
  end

  def unsubscribe() do
    :ok = Phoenix.PubSub.unsubscribe(ExChatOtp.PubSub, pubsub_topic)
  end
end
