defmodule TodoApp.List do
  defstruct auto_id: 1, entries: %{}

  @behaviour Access
  # implement the access behaviour through the three callbacks necessary

  def fetch(list, key) do
    :maps.find(list, key)
  end

  def get_and_update(map, key, fun) when is_function(fun, 1) do
    current = Map.get(map, key)

    case fun.(current) do
      {get, update} ->
        {get, Map.put(map, key, update)}

      :pop ->
        {current, Map.delete(map, key)}

      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
    end
  end

  def pop(map, key, default \\ nil) do
    case :maps.take(key, map) do
      {_, _} = tuple -> tuple
      :error -> {default, map}
    end
  end

  defimpl String.Chars, for: TodoApp.List do
    def to_string(list) do
      "#LIST: auto_id -> #{list.auto_id}, entries -> #{list.entries}"
    end
  end

  defimpl String.Chars, for: Map do
    def to_string(map) do
      "#{Map.keys(map)}"
    end
  end
end
