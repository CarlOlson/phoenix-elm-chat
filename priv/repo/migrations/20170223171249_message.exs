defmodule Chat.Repo.Migrations.Message do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :username, :string
      add :body, :string

      timestamps()
    end
  end
end
