defmodule ExChat.User do
  @moduledoc "Represents a chat user who can be members of chat channels"

  defstruct id: "",
            email: "",
            username: ""

  def new(opts) do
    %__MODULE__{
      id: Keyword.fetch!(opts, :id),
      email: Keyword.fetch!(opts, :email),
      username: Keyword.fetch!(opts, :username),
    }
  end
end
