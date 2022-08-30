defmodule ExChatDal.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias ExChatDal.Repo

      import Ecto
      import Ecto.Query
      import ExChatDal.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ExChatDal.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ExChatDal.Repo, {:shared, self()})
    end

    :ok
  end
end
