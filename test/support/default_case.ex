defmodule Chat.DefaultCase do
  use ExUnit.CaseTemplate

  @sleep_time 10

  using do
    quote do
      import Chat.DefaultCase
    end
  end

  def wait_for(func) do
    result = func.()
    if result do
      result
    else
      :timer.sleep(@sleep_time)
      wait_for(func)
    end
  end
end
