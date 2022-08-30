ExUnit.configure seed: 1

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(ExChatDal.Repo, :manual)

