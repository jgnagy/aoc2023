defmodule Mix.Tasks.Aoc2023.Day1 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day1.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day1 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day1.part1("data/samples/day1.p1.txt")
      142

  """
  def part1(data_file \\ "data/day1.txt") do
    regex_component = "\\d"

    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&extract_first_and_last_numbers(&1, regex_component))
    |> Enum.reduce(0, &(&1 + &2))
  end

  @doc """
  Solve Day1 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day1.part2("data/samples/day1.p2.txt")
      281

  """
  def part2(data_file \\ "data/day1.txt") do
    regex_component = "\\d|one|two|three|four|five|six|seven|eight|nine"

    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&extract_first_and_last_numbers(&1, regex_component))
    |> Enum.reduce(0, &(&1 + &2))
  end

  defp extract_first_and_last_numbers(line, regex) do
    first = Regex.compile!("(#{regex}).*$") |> Regex.run(line) |> List.last
    last = Regex.compile!("^.*(#{regex})") |> Regex.run(line) |> List.last

    [first, last]
    |> List.flatten()
    |> Enum.map(&convert_to_number(&1))
    |> Enum.join()
    |> String.to_integer()
  end

  defp convert_to_number(number) do
    case number do
      "one" -> "1"
      "two" -> "2"
      "three" -> "3"
      "four" -> "4"
      "five" -> "5"
      "six" -> "6"
      "seven" -> "7"
      "eight" -> "8"
      "nine" -> "9"
      _ -> number
    end
  end
end
