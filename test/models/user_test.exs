defmodule Chat.UserTest do
  use Chat.ModelCase

  alias Chat.User

  @valid_attrs %{username: "user"}
  @registration_attrs %{username: "user", password: "password"}
  @invalid_attrs %{}
  @short_password "12345"

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "registration changeset hashes password" do
    changeset = User.registration_changeset(%User{}, @registration_attrs)
    assert changeset.valid?
    assert String.contains?(changeset.changes.password_hash, "$2b$")
  end

  test "passwords must be long enough" do
    changeset = User.registration_changeset(
      %User{},
      Map.put(@registration_attrs, :password, @short_password))
    refute changeset.valid?
  end
end
