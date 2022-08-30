defmodule ExChatDalTest do
  use ExChatDal.RepoCase

  alias ExChatDal.{
    Repo,
    Channels,
    Accounts,
    Posts
  }

  alias Channels.Channel
  alias Posts.Post
  alias Accounts.{User, UserToken, UserNotifier}

  doctest ExChatDal.Channels, import: true
  doctest ExChatDal.Posts, import: true
end
