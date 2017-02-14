defmodule Chat.ChatChannelTest do
  use Chat.ChannelCase

  alias Chat.ChatChannel

  setup do
    {:ok, _, socket} =
      socket()
      |> subscribe_and_join(ChatChannel, "chat:lobby", %{"username" => "name"})

    {:ok, socket: socket}
  end

  test "shout broadcasts to chat:lobby", %{socket: socket} do
    push socket, "shout", %{"message" => "hello"}
    assert_broadcast "shout", %{"message" => "hello"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
