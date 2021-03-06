defmodule Chat.IntegrationTest do
  use ExUnit.Case
  use Chat.DefaultCase
  use Hound.Helpers
  use Chat.ChannelCase

  import Ecto.Query

  alias Chat.Message
  alias Chat.Repo

  @moduletag timeout: (if System.get_env("TRAVIS"), do: 10_000, else: 1_000)

  # Start hound session and destroy when tests are run
  hound_session()

  setup config do
    Repo.delete_all(Message)
    {:ok, config}
  end

  test "homepage has a title" do
    navigate_to("/")

    assert page_title() =~ ~r/Chat/i
  end

  test "should be able to login" do
    login()

    assert visible_page_text() =~ ~r/Chat now.../
  end

  @tag :not_travis
  test "should display sent messages" do
    login()

    send_message("hello")

    :timer.sleep(100)
    assert wait_for_text(~r/hello/)
  end

  @tag :not_travis
  test "should display connected users" do
    login()

    assert wait_for_text(~r/Carl/)
  end

  @tag :not_travis
  test "should not show logged out users" do
    add_message("bob", "hello")

    login()
    wait_for_text(~r/hello/i)

    refute (
      find_element(:class, "mdl-list")
      |> inner_text() =~ ~r/bob/)
  end

  @tag :not_travis
  test "should be able to delete messages" do
    login()

    send_message("hello")

    wait_for_visible_text(~r/hello/)
    wait_for_element(:class, "delete-me")
    |> click()

    assert wait_for(fn ->
      !(visible_page_text() =~ ~r/hello/)
    end)
  end

  @tag :not_travis
  test "should remove deleted messages from the database" do
    add_message("Carl", "hello")
    id = Repo.one from msg in Message, select: msg.id

    login()

    wait_for_visible_text(~r/hello/)
    wait_for_element(:class, "delete-me")
    |> click()

    assert wait_for(fn ->
      Repo.get(Message, id) == nil
    end)
  end

  @tag :not_travis
  test "should respond to other's delete events" do
    message = add_message("bob", "hello")

    login()
    wait_for_text(~r/hello/)

    {:ok, _, socket} =
      socket()
      |> subscribe_and_join(Chat.ChatChannel, "chat:lobby", %{"username" => "bob"})
    broadcast_from socket, "delete", %{ "uuid" => message.id }

    assert wait_for(fn ->
      !(visible_page_text() =~ ~r/hello/)
    end)
  end

  @tag :not_travis
  test "should show previously sent messages" do
    add_message("bob", "hello")

    login()

    assert wait_for_text(~r/hello/)
    assert wait_for_text(~r/bob/)
  end

  @tag :not_travis
  test "should remove users on disconnect" do
    login()

    socket = subscribe_and_join!(
      socket(),
      Chat.ChatChannel,
      "chat:lobby",
      %{"username" => "bob"})
    wait_for_text(~r/bob/)

    Process.unlink(socket.channel_pid)
    close(socket)

    assert wait_for(fn ->
      !(page_source() =~ ~r/bob/)
    end)
  end

  defp send_message(text) do
    wait_for_element(:tag, "input")
    |> input_into_field(text)

    send_keys(:enter)
  end

  defp login() do
    navigate_to("/")

    wait_for_element(:tag, "input")
    |> fill_field("Carl")

    wait_for_element(:tag, "button")
    |> click()

    wait_for(fn ->
      !(visible_page_text() =~ ~r/Login/i)
    end)
  end

  defp wait_for_element(query_type, query) do
    wait_for(fn ->
      case search_element(query_type, query) do
        {:error, _} -> false
        {:ok, element} -> element
      end
    end)
  end

  defp wait_for_visible_text(regex) do
    wait_for(fn ->
      visible_page_text() =~ regex
    end)
  end

  defp wait_for_text(regex) do
    wait_for(fn ->
      page_source()
      |> Floki.parse()
      |> Floki.text() =~ regex
    end)
  end
end
