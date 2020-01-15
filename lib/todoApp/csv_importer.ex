defmodule TodoApp.CsvImporter do
  def import(file) do
    file
    |> get_raw_data()
    |> form_data()
    |> TodoApp.TodoList.new()
  end

  # PRIVATE

  defp form_data(stream) do
    stream
    |> Stream.map(fn s -> String.split(s, ~r/\n/, trim: true) end)
    |> Stream.map(fn [v] -> String.split(v, ",") end)
    |> Enum.map(fn [date, title] ->
      [year, month, day] =
        String.split(date, ~r/\//, trim: true) |> Enum.map(&String.to_integer/1)

      {:ok, date} = Date.new(year, month, day)

      %{
        date: date,
        title: title
      }
    end)
  end

  defp get_raw_data(file) do
    file |> get_path() |> File.stream!()
  end

  defp get_path(file) do
    "../assets/#{file}" |> Path.expand(__DIR__)
  end
end
