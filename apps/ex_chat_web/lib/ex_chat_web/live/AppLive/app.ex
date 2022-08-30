defmodule ExChatWeb.Live.App do
  use ExChatWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    {:ok, socket}
  end
end
