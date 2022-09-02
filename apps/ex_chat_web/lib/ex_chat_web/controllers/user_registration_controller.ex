defmodule ExChatWeb.UserRegistrationController do
  use ExChatWeb, :controller

  alias ExChatDal.Accounts
  alias ExChatDal.Accounts.User
  alias ExChatWeb.UserAuth

  def new(conn, _params) do
    changeset = Accounts.change_user_registration(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(conn, :edit, &1)
          )

        conn
        |> put_flash(:info, "User created successfully.")
        |> UserAuth.log_in_user(user)
        |> dbg()

      {:error, %Ecto.Changeset{} = changeset} ->
        dbg(render(conn, "new.html", changeset: changeset))
    end
  end
end
