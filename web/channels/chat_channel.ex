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
    ensure_directory_started()
    user_connected(socket.assigns.username)

    broadcast socket, "connect", %{ "username" => socket.assigns.username }

    send_all_messages(socket)
    send_all_connected(socket)

    {:noreply, socket}
  end

  defp send_all_messages(socket) do
    Repo.all(Message)
    |> Enum.each(fn message ->
      push socket, "shout", %{ "username" => message.username,
                               "body" => message.body,
                               "uuid" => message.id }
    end)
  end

  defp send_all_connected(socket) do
    Enum.each(connected_users(),
      fn username ->
        push socket, "connect", %{"username" => username}
      end)
  end

  defp ensure_directory_started() do
    Agent.start_link(fn -> MapSet.new end, [name: __MODULE__])
  end

  defp user_connected(username) do
    Agent.update(__MODULE__, &MapSet.put(&1, username))
  end

  defp user_disconnected(username) do
    Agent.update(__MODULE__, &MapSet.delete(&1, username))
  end

  defp connected_users() do
    Agent.get(__MODULE__, &MapSet.to_list(&1))
  end
end
