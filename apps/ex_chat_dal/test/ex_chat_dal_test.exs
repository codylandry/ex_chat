defmodule ExChatDalTest do
  use ExUnit.Case
  doctest ExChatDal

  test "greets the world" do
    assert ExChatDal.hello() == :world
  end
end
