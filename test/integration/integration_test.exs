defmodule Chat.IntegrationTest do
  use ExUnit.Case
  use Hound.Helpers

  alias Chat.Message
  alias Chat.Repo

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Chat.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(Chat.Repo, {:shared, self()})
    end

    :ok
  end

  @moduletag timeout: (if System.get_env("TRAVIS"), do: 10_000, else: 1_000)
  @sleep_time 10

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

  @tag :not_travis
  test "should display sent messages" do
    login()

    send_message("hello")
    wait_for_text(~r/hello/)

    assert visible_page_text() =~ ~r/hello/
  end

  @tag :not_travis
  test "should display users" do
    login()

    send_message("hello")
    wait_for_text(~r/carl/i)

    assert visible_page_text() =~ ~r/carl/i
  end

  @tag :not_travis
  test "should be able to delete messages" do
    login()

    send_message("hello")
    wait_for_text(~r/hello/)

    wait_for_element(:class, "delete-me")
    |> click()

    wait_for(fn ->
      !(visible_page_text() =~ ~r/hello/)
    end)

    refute visible_page_text() =~ ~r/hello/
  end

  @tag :not_travis
  test "should show previously sent messages" do
    %Message{}
    |> Message.changeset(%{username: "bob", body: "hello"})
    |> Repo.insert!

    login()

    wait_for_text(~r/hello/)
    assert visible_page_text() =~ ~r/hello/

    wait_for_text(~r/bob/)
    assert visible_page_text() =~ ~r/bob/
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

  defp wait_for(func) do
    result = func.()
    unless result do
      :timer.sleep(@sleep_time)
      wait_for(func)
    end
    result
  end

  defp wait_for_element(query_type, query) do
    wait_for(fn ->
      case search_element(query_type, query) do
        {:error, _} -> false
        {:ok, element} -> element
      end
    end)
  end

  defp wait_for_text(regex) do
    wait_for(fn ->
      visible_page_text() =~ regex
    end)
  end
end
