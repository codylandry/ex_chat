defmodule ExChatDalTest do
  use ExChatDal.RepoCase

  alias ExChatDal.{
    Channels,
    Accounts,
  }

  alias Channels.Channel

  doctest ExChatDal.Channels, import: true
  doctest ExChatDal.Posts, import: true
end
