# Run with elixir hello_actors.exs

import :timer, only: [ sleep: 1 ]

defmodule Talker do

  def loop do

    receive do
      {:greet, name} -> IO.puts("Hello #{name}")
      {:praise, name} -> IO.puts("#{name}, you're amazing")
      {:celebrate, name, age} -> IO.puts("Here's to another #{age} years, #{name}")
    end
    loop #actor : infinite loop
  end
end


pid = spawn(&Talker.loop/0)
send(pid, {:greet, "Luke"})
send(pid, {:praise, "Yoda"})
send(pid, {:celebrate, "Yoda", 42})
sleep(1000)
