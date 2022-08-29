defmodule ExChatDal.Repo do
  use Ecto.Repo,
    otp_app: :ex_chat_dal,
    adapter: Ecto.Adapters.Postgres
end
