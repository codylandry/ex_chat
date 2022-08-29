defmodule ExChat.User do
  defstruct [
    id: "",
    name: ""
  ]

  def new(opts) do
    %__MODULE__{
      id: Keyword.fetch!(opts, :id),
      name: Keyword.fetch!(opts, :name)
    }
  end
end
