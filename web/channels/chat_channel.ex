defmodule Chat.ChatChannel do
  use Chat.Web, :channel

  alias Chat.Message
  alias Chat.Repo

  def join("chat:lobby", %{ "username" => username }, socket) do
    socket = assign socket, :username, username
    send(self(), :connect)
    {:ok, socket}
  end

  def handle_in("shout", %{ "body" => body }, socket) do
    message =
      %Message{}
      |> Message.changeset(%{
          username: socket.assigns.username,
          body: body })
      |> Repo.insert!()

    broadcast socket, "shout", %{ "username" => socket.assigns.username,
                                  "body" => body,
                                  "uuid" => message.id }

    {:noreply, socket}
  end

  def handle_in("delete", %{ "uuid" => uuid }, socket) do
    msg = Repo.get(Message, uuid)

    if (msg && msg.username == socket.assigns.username) do
      Repo.delete(msg)
      broadcast socket, "delete", %{ "uuid" => uuid }
    end

    {:noreply, socket}
  end

  def handle_info(:connect, socket) do
    broadcast socket, "connect", %{ "username" => socket.assigns.username }

    Repo.all(Message)
    |> Enum.each(fn message ->
      push socket, "shout", %{ "username" => message.username,
                               "body" => message.body,
                               "uuid" => message.id }
    end)

    {:noreply, socket}
  end
end
