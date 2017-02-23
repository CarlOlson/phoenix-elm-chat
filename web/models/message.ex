defmodule Chat.Message do
  use Chat.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "messages" do
    field :username, :string
    field :body, :string

    timestamps()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:username, :body])
    |> validate_required([:username, :body])
  end
end
