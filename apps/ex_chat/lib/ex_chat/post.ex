defmodule ExChat.Post do
  @moduledoc "Represents a single 'post' including its author, content and related channel id"
  alias ExChat.User

  defstruct id: "",
            content: "",
            author: nil,
            channel_id: ""

  def new(opts) do
    %__MODULE__{
      id: Keyword.fetch!(opts, :id),
      content: Keyword.fetch!(opts, :content),
      author: Keyword.fetch!(opts, :user),
      channel_id: Keyword.fetch!(opts, :channel_id)
    }
  end
end
