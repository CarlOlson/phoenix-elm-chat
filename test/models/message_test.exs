defmodule Chat.MessageTest do
  use Chat.ModelCase

  alias Chat.Message

  @valid_message %{username: "carl", body: "sup"}

  test "messages can be added to the database" do
    inital_count = message_count()

    %Message{}
    |> Message.changeset(@valid_message)
    |> Repo.insert

    assert message_count() == inital_count + 1
  end

  defp message_count() do
    Repo.one from x in Message, select: count(x.id)
  end
end
