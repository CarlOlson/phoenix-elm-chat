defmodule Chat.IntegrationTest do
  use ExUnit.Case
  use Hound.Helpers

  use Chat.ChannelCase
  alias Chat.ChatChannel

  # Start hound session and destroy when tests are run
  hound_session()

  test "homepage has a title" do
    navigate_to("/")

    assert page_title() =~ ~r/Chat/i
  end

  test "should be able to login" do
    login()

    assert visible_page_text() =~ ~r/Chat now.../
  end

  test "should display sent messages" do
    login()

    send_message("carl", "hello")
    find_element(:tag, "p")

    assert visible_page_text() =~ ~r/hello/
  end

  test "should display users" do
    login()

    send_message("carl", "hello")
    find_element(:tag, "span")

    assert visible_page_text() =~ ~r/carl/
  end

  defp send_message(user, text) do
    {:ok, _, socket} =
      socket()
      |> subscribe_and_join(ChatChannel, "chat:lobby", %{"username" => user})
    push socket, "shout", %{"message" => text}
  end

  defp login() do
    navigate_to("/")

    element = find_element(:tag, "input")
    fill_field(element, "Carl")

    find_element(:tag, "button")
    |> click()
  end
end
