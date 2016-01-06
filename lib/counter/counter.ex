# Using three argument form of spawn counter = spawn(Counter, :loop, [1])
# Bidirectional communication => send self messages
defmodule Counter do

  def start(count) do
    pid=spawn(__MODULE__,:loop,[count])
    Process.register(pid,:counter)
    pid
  end

  def next do
    ref=make_ref()
    send(:counter, {:next, self(), ref})
    receive do
      {:ok, ^ref,count} -> count
    end
  end

  def loop(count) do
    receive do
      {:next, sender, ref} ->
        #reply with a tuple and a ref which ensure the reply is correctly identified..
        send(sender, {:ok, ref, count})
        loop(count+1)
    end
  end
end
