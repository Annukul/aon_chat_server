defmodule AonChatWeb.ChatChannel do
  use AonChatWeb, :channel

  def join("room:*", _message, socket) do
    {:ok, socket}
  end

  def handle_in("new_msg", params, socket) do
    broadcast(socket, "new_msg", %{params: params})
    {:noreply, socket}
  end

  def handle_out("user_joined", msg, socket) do
    push(socket, "user_joined", msg)
    {:noreply, socket}
  end
end
