defmodule TodoApp.MultiDict do
  def new, do: %{}

  def add(list, key, value) do
    Map.update(list, key, [value], &[value | &1])
  end

  def get(list, key) do
    Map.get(list, key, [])
  end
end
