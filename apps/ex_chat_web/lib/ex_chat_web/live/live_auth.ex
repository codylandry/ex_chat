defmodule ExChatWeb.Live.Auth do
  import Phoenix.LiveView

  alias ExChatDal.Accounts

  def on_mount(:default, _params, %{"user_token" => user_token} = _session, socket) do
    user = Accounts.get_user_by_session_token(user_token)
    socket =
      assign_new(socket, :current_user, fn ->

      end)

    cond do
      !user ->
        {:halt, redirect(socket, to: "/users/log_in")}
      !user.confirmed_at ->
        {:halt, redirect(socket, to: "/users/confirm")}
      user ->
        {:cont, assign(socket, :current_user, user)}
    end
  end
end
