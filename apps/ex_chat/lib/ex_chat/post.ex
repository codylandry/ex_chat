defmodule ExChat.Post do
  alias ExChat.{User}

  defstruct [
    id: "",
    content: "",
    user: nil,
    channel_id: ""
  ]

  def new(opts) do
    %__MODULE__{
      id: Keyword.fetch!(opts, :id),
      content: Keyword.fetch!(opts, :content),
      user: Keyword.fetch!(opts, :user),
      channel_id: Keyword.fetch!(opts, :channel_id)
    }
  end
end
