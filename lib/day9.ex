defmodule Mix.Tasks.Aoc2023.Day9 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day9.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day9 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day9.part1("data/samples/day9.txt")
      114

  """
  def part1(data_file \\ "data/day9.txt") do
    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&extract_numbers(&1))
    |> Enum.map(&extend_series(&1))
    |> Enum.map(&(&1 |> List.last()))
    |> Enum.sum()
  end

  @doc """
  Solve Day9 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day9.part2("data/samples/day9.txt")
      2

  """
  def part2(data_file \\ "data/day9.txt") do
    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&extract_numbers(&1))
    |> Enum.map(&prepend_series(&1))
    |> Enum.map(&(&1 |> List.first()))
    |> Enum.sum()
  end

  defp extract_numbers(line) do
    line
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  @doc """
  For a list of numbers, finds the next number based on the pattern
  in the existing numbers.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day9.extend_series([1, 2, 3, 4, 5])
      [1, 2, 3, 4, 5, 6]

      iex> Mix.Tasks.Aoc2023.Day9.extend_series([4, 7, 11, 16, 22])
      [4, 7, 11, 16, 22, 29]
  """
  def extend_series(numbers) do
    differences = find_differences(numbers)

    expected_diff = List.first(differences)

    all_diffs_match = differences
    |> Enum.all?(&(&1 == expected_diff))

    if all_diffs_match do
      [numbers, List.last(numbers) + expected_diff]
      |> List.flatten()
    else
      new_diffs = differences
      |> extend_series()

      Enum.concat(
        numbers,
        [List.last(numbers) + List.last(new_diffs)]
      )
    end
  end

  @doc """
  For a list of numbers, finds the previous number based on the pattern
  in the existing numbers.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day9.prepend_series([1, 2, 3, 4, 5])
      [0, 1, 2, 3, 4, 5]

      iex> Mix.Tasks.Aoc2023.Day9.prepend_series([4, 7, 11, 16, 22])
      [2, 4, 7, 11, 16, 22]

      iex> Mix.Tasks.Aoc2023.Day9.prepend_series([-4, 0, 7, 18, 34])
      [-6, -4, 0, 7, 18, 34]
  """
  def prepend_series(numbers) do
    numbers
    |> Enum.reverse()
    |> extend_series()
    |> Enum.reverse()
  end

  defp find_differences(numbers) do
    {differences, _} = numbers
    |> Enum.reduce({[], 0}, fn number, {differences, last} ->
      if differences == [] && last == 0 do
        {[], number}
      else
        {
          Enum.concat(differences, [number - last]),
          number
        }
      end
    end)

    differences
  end
end
