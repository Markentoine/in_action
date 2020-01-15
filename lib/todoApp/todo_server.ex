defmodule TodoApp.TodoServer do
  alias TodoApp.TodoList
  # API

  def start() do
    Process.register(self(), :todo)
    state_pid = spawn(fn -> loop() end)
    Process.register(state_pid, :keep_state)
    {:ok, state_pid}
  end

  def add_entry(entry) do
    send(:keep_state, {:add, entry})
  end

  def entries(date) do
    send(:keep_state, {:entries, date})

    receive do
      {:ok, entries} ->
        entries
    after
      5000 -> {:error, :timeout}
    end
  end

  def update_entry(id, updater_fun) do
    send(:keep_state, {:update, id, updater_fun})
  end

  def delete_entry(id) do
    send(:keep_state, {:delete, id})
  end

  # IMPLEMENTATION
  defp loop() do
    loop(TodoList.new())
  end

  defp loop(list) do
    new_list =
      receive do
        msg -> handle_message(msg, list)
      end

    loop(new_list)
  end

  defp handle_message({:add, entry}, list) do
    TodoList.add_entry(list, entry)
  end

  defp handle_message({:entries, date}, list) do
    entries = TodoList.entries(list, date)
    send(:todo, {:ok, entries})
  end

  defp handle_message({:update, id, updater_fun}, list) do
    TodoList.update_entry(list, id, updater_fun)
  end

  defp handle_message({:delete, id}, list) do
    TodoList.delete_entry(list, id)
  end
end
