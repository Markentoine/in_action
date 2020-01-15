defmodule TodoApp.TodoList do
  def new, do: %TodoApp.List{}

  def new(entries) do
    # grâce à l'implémentation de Collectable pour List, on peut simplifier élégamment en
    for entry <- entries, into: new(), do: entry
    # entries
    # |> Enum.reduce(new(), &add_entry(&2, date: &1.date, title: &1.title))
  end

  def add_entry(todo_list, %{date: date, title: title}) do
    new_entry = create_entry(id: todo_list.auto_id, date: date, title: title)
    new_entries = update_entries(todo_list.entries, new_entry)
    %TodoApp.List{todo_list | auto_id: todo_list.auto_id + 1, entries: new_entries}
  end

  defimpl Collectable, for: TodoApp.List do
    def into(original) do
      {original, &into_callback/2}
    end

    defp into_callback(todo_list, {:cont, entry}) do
      TodoApp.TodoList.add_entry(todo_list, entry)
    end

    defp into_callback(todo_list, :done), do: todo_list
    defp into_callback(_todo_list, :halt), do: :ok
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Stream.filter(fn {_, entry} -> entry.date == date end)
    |> Enum.map(fn {_, entry} -> entry end)
  end

  def entries(todo_list) do
    todo_list.entries
    |> IO.inspect()
    |> Enum.map(& &1)
  end

  def update_entry(todo_list, [], _), do: todo_list

  def update_entry(todo_list, [%TodoApp.Entry{} = old_entry], updater_fun) do
    old_id = old_entry.id
    new_entry = %TodoApp.Entry{id: ^old_id} = updater_fun.(old_entry)

    # put_in => put a value in a nested structure; using Access module
    put_in(todo_list, [:entries, new_entry.id], new_entry)
  end

  def update_entry(todo_list, id, updater_fun) do
    update_entry(todo_list, fetch_entry(todo_list.entries, id), updater_fun)
  end

  def delete_entry(todo_list, id) do
    case Access.pop(todo_list.entries, id) do
      {nil, _} -> todo_list
      {_, new_entries} -> put_in(todo_list, [:entries], new_entries)
    end
  end

  # PRIVATE

  defp fetch_entry(list, id) do
    case Map.fetch(list, id) do
      :error -> []
      {:ok, entry} -> [entry]
    end
  end

  defp update_entries(list, entry) do
    Map.put(list, entry.id, entry)
  end

  defp create_entry(id: id, date: date, title: title) do
    %TodoApp.Entry{id: id, date: date, title: title}
  end

  # def entries(todo_list, date), do: TodoApp.MultiDict.get(todo_list, date)
end
