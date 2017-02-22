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

  test "shouts should have a uuid", %{ socket: socket } do
    push socket, "shout", %{"message" => "hello"}

    assert_broadcast "shout", %{"uuid" => _}
  end

  test "shouts should have different uuids", %{socket: socket} do
    push socket, "shout", %{"message" => "1"}
    push socket, "shout", %{"message" => "2"}

    assert_broadcast "shout", %{"message" => "1", "uuid" => uuid1}
    assert_broadcast "shout", %{"message" => "2", "uuid" => uuid2}
    assert uuid1 != uuid2
  end
end
