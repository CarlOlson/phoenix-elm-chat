defmodule Chat.IntegrationTest do
  use ExUnit.Case
  use Hound.Helpers

  @moduletag timeout: 10000
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
    wait_for(fn ->
      visible_page_text() =~ ~r/hello/
    end)

    assert visible_page_text() =~ ~r/hello/
  end

  @tag :not_travis
  test "should display users" do
    login()

    send_message("hello")
    wait_for(fn ->
      visible_page_text() =~ ~r/carl/i
    end)

    assert visible_page_text() =~ ~r/carl/i
  end

  @tag :not_travis
  test "should be able to delete messages" do
    login()

    send_message("hello")
    wait_for(fn ->
      case search_element(:class, "delete-me") do
        {:error, _} ->
          false
        {:ok, _} ->
          visible_page_text() =~ ~r/hello/
      end
    end)

    find_element(:class, "delete-me")
    |> click()

    refute visible_page_text() =~ ~r/hello/
  end

  defp send_message(text) do
    wait_for(fn ->
      case search_element(:tag, "input") do
        {:error, _} ->
          false
        {:ok, _} ->
          true
      end
    end)

    find_element(:tag, "input")
    |> input_into_field(text)

    send_keys(:enter)
  end

  defp login() do
    navigate_to("/")

    wait_for(fn ->
      visible_page_text() =~ ~r/Login/
    end)

    element = find_element(:tag, "input")
    fill_field(element, "Carl")

    find_element(:tag, "button")
    |> click()
  end

  def wait_for(func) do
    unless func.() do
      :timer.sleep(@sleep_time)
      wait_for(func)
    end
  end
end
