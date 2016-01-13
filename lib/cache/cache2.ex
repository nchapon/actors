defmodule CacheGenServer do
  use GenServer

  # External API
  def start_link do
    # Call erlang function
    :gen_server.start_link({:local, :cache}, __MODULE__, {HashDict.new, 0}, [])
  end

  def put(url, page) do
    :gen_server.cast(:cache, {:put, url, page})
  end

  def get(url) do
    :gen_server.call(:cache, {:get, url})
  end

  def size do
    :gen_server.call(:cache, {:size})
  end

  # GenServer implementation
  # Server handlers
  # request, state (async => noreply)
  def handle_cast({:put, url, page},{pages,size}) do
    new_pages = Dict.put(pages,url,page)
    new_size = size + byte_size(page)
    {:noreply, {new_pages,new_size}}
  end

  # request, sender, state (sync => reply)
  def handle_call({:get, url}, _from, {pages,size}) do
    {:reply, pages[url], {pages,size}}
  end

  def handle_call({:size}, _from, {pages,size}) do
    {:reply, size, {pages,size}}
  end

end

defmodule CacheGenServerSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_args) do
    workers = [worker(CacheGenServer, [])]
    supervise(workers, strategy: :one_for_one)
  end

end
