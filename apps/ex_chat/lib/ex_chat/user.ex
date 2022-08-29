defmodule ExChat.User do
  @moduledoc "Represents a chat user who can be members of chat channels"

  defstruct id: "",
            name: ""

  def new(opts) do
    %__MODULE__{
      id: Keyword.fetch!(opts, :id),
      name: Keyword.fetch!(opts, :name)
    }
  end
end
