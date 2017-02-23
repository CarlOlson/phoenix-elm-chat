defmodule Chat.ChatChannel do
  use Chat.Web, :channel

  alias Chat.Message

  def join("chat:lobby", %{ "username" => username }, socket) do
    socket = assign socket, :username, username
    send(self(), :connect)
    {:ok, socket}
  end

  def handle_in("shout", %{ "message" => body }, socket) do
    message =
      %Message{}
      |> Message.changeset(%{
          username: socket.assigns.username,
          body: body })
      |> Repo.insert!()

    broadcast socket, "shout", %{ "username" => socket.assigns.username,
                                  "message" => body,
                                  "uuid" => message.id }

    {:noreply, socket}
  end

  def handle_info(:connect, socket) do
    broadcast socket, "connect", %{ "username" => socket.assigns.username }
    {:noreply, socket}
  end
end
