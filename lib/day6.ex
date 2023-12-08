defmodule Mix.Tasks.Aoc2023.Day6 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day6.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day6 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day6.part1("data/samples/day6.txt")
      288

  """
  def part1(data_file \\ "data/day6.txt") do
    data_file
    |> calculate_games()
    |> count_better_games()
    |> Enum.product()
  end

  @doc """
  Solve Day1 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day6.part2("data/samples/day6.txt")
      71503

  """
  def part2(data_file \\ "data/day6.txt") do
    data_file
    |> calculate_games(true)
    |> count_better_games()
    |> Enum.product()
  end

  def calculate_games(data_file, part2 \\ false) do
    [times, distances] = data_file
    |> File.read!()
    |> String.split("\n", trim: true)

    times = if part2 do
              extract_numbers(times, true)
            else
              extract_numbers(times)
            end

    distances = if part2 do
                  extract_numbers(distances, true)
                else
                  extract_numbers(distances)
                end

    Enum.zip(times, distances)
  end

  @doc """
  Extract some game numbers from a line of data.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day6.extract_numbers("Times: 1 2 3 4 5")
      [1, 2, 3, 4, 5]

  """
  def extract_numbers(line) do
    [_ | numbers] = line |> String.split(~r/\s+/, trim: true)

    numbers
    |> Enum.map(&String.to_integer(&1))
  end

  @doc """
  Extract some game numbers from a line of data for part 2.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day6.extract_numbers("Times: 1 2 3 4 5", true)
      [12345]

  """
  def extract_numbers(line, true) do
    [_ | numbers] = line |> String.split(~r/\s+/, trim: true)

    number = numbers
    |> Enum.join()
    |> String.to_integer()

    [number]
  end

  @doc """
  Calculate a distance based on a total game time.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day6.calculate_distances(3)
      [0, 2, 2, 0]

  """
  def calculate_distances(time) do
    0..time
    |> Enum.map(fn x -> ((time - x) * x) end)
  end

  def count_better_games(games) do
    Enum.map(
      games,
      fn {time, distance} ->
        calculate_distances(time)
        |> Enum.count(fn d -> d > distance end)
      end
    )
  end
end
