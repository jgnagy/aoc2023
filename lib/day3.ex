defmodule Mix.Tasks.Aoc2023.Day3 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day3.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day3 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day3.part1("data/samples/day3.txt")
      4361

  """
  def part1(data_file \\ "data/day3.txt") do
    lines = data_file
    |> lines_from_data()

    [find_symbols(lines), find_numbers(lines)]
    |> find_adjacents()
    |> Enum.map(fn {_symbol, {_x, _y}, numbers} -> numbers end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.map(fn {number, _coordinates} -> number end)
    |> Enum.sum()
  end

  @doc """
  Solve Day3 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day3.part2("data/samples/day3.txt")
      467835

  """
  def part2(data_file \\ "data/day3.txt") do
    lines = data_file
    |> lines_from_data()

    [find_symbols(lines), find_numbers(lines)]
    |> find_adjacents()
    |> Enum.filter(fn {symbol, {_x, _y}, numbers} -> symbol == "*" && length(numbers) == 2 end)
    |> Enum.map(
      fn {_symbol, {_x, _y}, numbers} -> numbers
        |> Enum.map(fn {number, _} -> number end)
        |> Enum.product()
      end
    )
    |> Enum.sum()
  end

  def lines_from_data(data_file) do
    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.map(fn {line, index} -> {line, index * -1} end) # provides the y-axis
  end

  def find_symbols(lines) do
    lines
    |> Enum.map(fn {line, y} -> find_symbols_in_line(line, y) end)
    |> List.flatten()
  end

  def find_numbers(lines) do
    lines
    |> Enum.map(fn {line, y} -> find_numbers_in_line(line, y) end)
    |> List.flatten()
  end

  @doc """
  Extracts symbols with their x and y coordinates from a line.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day3.find_symbols_in_line("....+.#.", 1)
      [{"+", {4, 1}}, {"#", {6, 1}}]

  """
  def find_symbols_in_line(line, y) do
    symbol_regex = ~r/[^0-9.]/
    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.map(
      fn {char, x} -> if Regex.match?(symbol_regex, char), do: {char, {x, y}}, else: nil end
    )
    |> Enum.filter(&(&1 != nil))
  end

  @doc """
  Extracts part numbers with their x and y coordinate start and stop locations from a line.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day3.find_numbers_in_line(".23..345", 1)
      [{23, [{1, 1}, {2, 1}]}, {345, [{5, 1}, {6, 1}, {7, 1}]}]

  """
  def find_numbers_in_line(line, y, start \\ 0) do
    number_regex = ~r/^([^0-9]*)(\d+)(.*)$/

    case Regex.run(number_regex, line) do
      nil -> []
      [_, preceding_text, number, remainder] ->
        start = start + String.length(preceding_text)
        [
          {
            String.to_integer(number),
            for(n <- 0..(String.length(number) - 1), do: {start + n, y})
          }
        ] ++ find_numbers_in_line(remainder, y, start + String.length(number))
    end
  end

  def find_adjacents([symbols, numbers]) do
    symbols
    |> Enum.map(fn {symbol, {x, y}} -> {symbol, {x, y}, find_adjacent_numbers(x, y, numbers)} end)
    |> Enum.filter(fn {_, _, numbers} -> length(numbers) > 0 end)
  end

  @doc """
  Finds numbers adjacent to a coordinate.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day3.find_adjacent_numbers(
      ...>   5, 0, [{23, [{1, 1}, {2, 1}]}, {345, [{5, 1}, {6, 1}, {7, 1}]}]
      ...> )
      [{345, [{5, 1}, {6, 1}, {7, 1}]}]

  """
  def find_adjacent_numbers(x, y, numbers) do
    Enum.filter(
      numbers,
      fn {_number, coordinates} ->
        Enum.any?(coordinates, fn {x2, y2} -> x2 in (x - 1..x + 1) && y2 in (y - 1..y + 1) end)
      end
    )
  end
end
