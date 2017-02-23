defmodule Chat.ChatChannelTest do
  use Chat.ChannelCase

  alias Chat.ChatChannel
  alias Chat.Message

  @sleep_time 100

  setup do
    {:ok, _, socket} =
      socket()
      |> subscribe_and_join(ChatChannel, "chat:lobby", %{"username" => "carl"})

    {:ok, socket: socket}
  end

  test "shout broadcasts to chat:lobby", %{socket: socket} do
    push socket, "shout", %{"body" => "hello"}
    assert_broadcast "shout", %{"body" => "hello"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end

  test "shouts should have a uuid", %{ socket: socket } do
    push socket, "shout", %{"body" => "hello"}

    assert_broadcast "shout", %{"uuid" => _}
  end

  test "shouts should have different uuids", %{socket: socket} do
    push socket, "shout", %{"body" => "1"}
    push socket, "shout", %{"body" => "2"}

    assert_broadcast "shout", %{"body" => "1", "uuid" => uuid1}
    assert_broadcast "shout", %{"body" => "2", "uuid" => uuid2}
    assert uuid1 != uuid2
  end

  test "should be able to delete own comments", %{socket: socket} do
    message = add_message("carl", "hello")

    push socket, "delete", %{"uuid" => message.id}

    assert_broadcast "delete", %{"uuid" => _}
    refute Repo.get(Message, message.id)
  end

  test "should not be able to delete other's comments", %{socket: socket} do
    message = add_message("bob", "hello")

    push socket, "delete", %{uuid: message.id}

    :timer.sleep @sleep_time
    assert Repo.get(Message, message.id)
  end

  test "successful deletes should be broadcasted", %{socket: socket} do
    message = add_message("carl", "hello")

    push socket, "delete", %{uuid: message.id}
    assert_broadcast "delete", %{}
  end
end
