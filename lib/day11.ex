defmodule Mix.Tasks.Aoc2023.Day11 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day11.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day11 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day11.part1("data/samples/day11.txt")
      374

  """
  def part1(data_file \\ "data/day11.txt") do
    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> expand_input()
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, index},acc -> build_point(acc, index, line) end)
    |> Enum.filter(fn {_, value} -> value end)
    |> Enum.map(fn {point, _} -> point end)
    |> Combination.combine(2)
    |> Enum.map(fn [{x1, y1}, {x2, y2}] -> abs(x1 - x2) + abs(y1 - y2) end)
    |> Enum.sum()
  end

  @doc """
  Solve Day11 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day11.part2("data/samples/day11.txt", 2)
      374

      iex> Mix.Tasks.Aoc2023.Day11.part2("data/samples/day11.txt", 10)
      1030

      iex> Mix.Tasks.Aoc2023.Day11.part2("data/samples/day11.txt", 100)
      8410

  """
  def part2(data_file \\ "data/day11.txt", multiple \\ 1_000_000) do
    raw_input_lines = data_file
    |> File.read!()
    |> String.split("\n", trim: true)

    y_worth = raw_input_lines
    |> Enum.map(fn (line) -> if row_contains_galaxy?(line), do: 1, else: multiple end)

    x_worth = raw_input_lines
    |> Enum.map(fn line -> String.split(line, "", trim: true) end)
    |> Aoc.Toolbox.transpose()
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.map(fn (line) -> if row_contains_galaxy?(line), do: 1, else: multiple end)

    raw_input_lines
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, index},acc -> build_point(acc, index, line) end)
    |> Enum.filter(fn {_, value} -> value end)
    |> Enum.map(fn {point, _} -> point end)
    |> Enum.map(
      fn {x, y} ->
        new_x = Enum.take(x_worth, x) |> Enum.sum()
        new_y = Enum.take(y_worth, abs(y)) |> Enum.sum()
        {new_x, new_y}
      end)
    |> Combination.combine(2)
    |> Enum.map(fn [{x1, y1}, {x2, y2}] -> abs(x1 - x2) + abs(y1 - y2) end)
    |> Enum.sum()
  end

  def expand_input(list, multiple \\ 2) do
    list
    |> duplicate_lines_if_necessary(multiple)
    |> Enum.map(fn line -> String.split(line, "", trim: true) end)
    |> Aoc.Toolbox.transpose()
    |> Enum.map(&Enum.join(&1, ""))
    |> duplicate_lines_if_necessary(multiple)
    |> Enum.map(fn line -> String.split(line, "", trim: true) end)
    |> Aoc.Toolbox.transpose()
    |> Enum.map(&Enum.join(&1, ""))
  end

  @doc """
  Determines if a row contains a galaxy.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day11.row_contains_galaxy?(".....")
      false

      iex> Mix.Tasks.Aoc2023.Day11.row_contains_galaxy?(".#...")
      true
  """
  def row_contains_galaxy?(row) do
    Regex.match?(~r/#/, row)
  end

  def duplicate_lines_if_necessary(lines, multiple) do
    lines
    |> Enum.map(
        fn line ->
          if !row_contains_galaxy?(line), do: List.duplicate(line, multiple), else: [line]
        end
      )
    |> List.flatten()
  end

  def build_point(graph, index, line) do
    y = index * -1

    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(graph, fn {char, x}, acc ->
      Map.put(acc, {x, y}, (if char == "#", do: true, else: false))
    end)
  end
end
