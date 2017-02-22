Application.ensure_all_started(:hound)

if System.get_env("TRAVIS") do
  ExUnit.configure(exclude: [skip: true, not_travis: true])
else
  ExUnit.configure(exclude: [skip: true])
end

ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(Chat.Repo, :manual)
