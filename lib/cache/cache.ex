defmodule Cache do

  def start_link do
    pid=spawn_link(__MODULE__,:loop, [HashDict.new, 0])
    Process.register(pid, :cache)
    pid
  end

  def put(url, page) do
    send(:cache, {:put, url, page})
  end

  def get(url) do
    ref=make_ref()
    send(:cache, {:get, self(), ref, url})
    receive do
      {:ok,^ref,page} -> page
    end
  end

  def size do
    ref=make_ref()
    send(:cache, {:size, self(), ref})
    receive do
      {:ok, ^ref, size} -> size
    end
  end

  def terminate do
    send(:cache, {:terminate})
  end

  def loop(pages, size) do
    receive do
      {:put, url, page} ->
        new_pages = Dict.put(pages,url,page)
        new_size = size + byte_size(page)
        loop(new_pages, new_size)
      {:get, sender, ref, url} ->
        send(sender, {:ok,ref,pages[url]})
        loop(pages, size)
      {:size, sender, ref} ->
        send(sender, {:ok, ref, size})
        loop(pages, size)
      {:terminate} -> # terminate request
    end
  end
end
