defmodule Chat.ChatChannel do
  use Chat.Web, :channel

  def join("chat:lobby", %{ "username" => username }, socket) do
    socket = assign socket, :username, username
    send(self(), :connect)
    {:ok, socket}
  end

  def handle_in("shout", %{ "message" => message }, socket) do
    broadcast socket, "shout", %{ "username" => socket.assigns.username,
                                  "message" => message }
    {:noreply, socket}
  end

  def handle_info(:connect, socket) do
    broadcast socket, "connect", %{ "username" => socket.assigns.username }
    {:noreply, socket}
  end
end
