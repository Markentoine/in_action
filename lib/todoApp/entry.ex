defmodule TodoApp.Entry do
  defstruct id: nil, date: nil, title: []

  defimpl String.Chars, for: TodoApp.Entry do
    def to_string(entry) do
      "Entry n°#{entry.id}"
    end
  end
end
