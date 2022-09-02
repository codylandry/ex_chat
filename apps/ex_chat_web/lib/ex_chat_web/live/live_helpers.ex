defmodule ExChatWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers
  alias Phoenix.LiveView.JS
  alias ExChatWeb.Router.Helpers, as: Routes

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.app_name_index_path(@socket, :index)}>
        <.live_component
          module={ExChatWeb.AppNameLive.FormComponent}
          id={@app_name.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.app_name_index_path(@socket, :index)}
          app_name: @app_name
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if @return_to do %>
          <%= live_patch "✖",
            to: @return_to,
            id: "close",
            class: "phx-modal-close",
            phx_click: hide_modal()
          %>
        <% else %>
          <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>✖</a>
        <% end %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  def post(assigns) do
    ~H"""
    <div class="app__main__post group mb-5 first-of-type:mb-0">
      <div class="app__main__post__email text-sm text-accent"><%= @post.author.email %></div>
      <div class="app__main__post__content text-md"><%= @post.content %></div>
      <%= if @post.author.id == @current_user.id do %>
        <span class="app__main__post__options dropdown dropdown-left">
          <button class="opacity-0 group-hover:opacity-100">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6.75a.75.75 0 110-1.5.75.75 0 010 1.5zM12 12.75a.75.75 0 110-1.5.75.75 0 010 1.5zM12 18.75a.75.75 0 110-1.5.75.75 0 010 1.5z" /></svg>
          </button>
          <ul tabindex="0" class="dropdown-content menu p-2 shadow bg-base-300 rounded-box w-52 z-10">
            <li><a phx-click="remove-post"
                phx-value-post_id={@post.id}>Delete</a></li>
          </ul>
        </span>

      <% end %>
    </div>
    """
  end

  def channel_row(assigns) do
    ~H"""
    <li class="group">
      <% cls = if @is_current_channel, do: "active", else: ""  %>
      <%= live_patch @channel.name, to: Routes.live_path(@socket, ExChatWeb.Live.App, @channel.id), class: cls <> " p-1 text-base-content"  %>
      <span class="dropdown dropdown-end absolute right-0 top-0 p-0 h-full">
        <button class="opacity-0 group-hover:opacity-100">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6.75a.75.75 0 110-1.5.75.75 0 010 1.5zM12 12.75a.75.75 0 110-1.5.75.75 0 010 1.5zM12 18.75a.75.75 0 110-1.5.75.75 0 010 1.5z" /></svg>
        </button>
        <ul tabindex="0" class="dropdown-content menu p-2 shadow bg-base-300 rounded-box">
          <%= if @user_is_member do %>
            <li><a phx-click="leave-channel" phx-value-channel_id={@channel.id}>Leave</a></li>
          <% else %>
            <li><a phx-click="join-channel" phx-value-channel_id={@channel.id}>Join</a></li>
          <% end %>
        </ul>
      </span>
    </li>
    """
  end

  def is_current_channel(channel, current_channel) do
    if !current_channel do
      false
    else
      channel.id == current_channel.id
    end
  end

  def difference_by(list1, list2, fun) do
    Enum.filter(list1, fn i ->
      !Enum.find_value(list2, fn g -> fun.(g) == fun.(i) end)
    end)
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end
end
