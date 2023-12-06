defmodule Mix.Tasks.Aoc2023.Day4 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day4.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day4 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day4.part1("data/samples/day4.txt")
      13

  """
  def part1(data_file \\ "data/day4.txt") do
    calculate_winning_numbers(data_file)
    |> Enum.map(&calculate_card_point_value(&1))
    |> Enum.sum()
  end

  @doc """
  Solve Day4 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day4.part2("data/samples/day4.txt")
      30

  """
  def part2(data_file \\ "data/day4.txt") do
    all_card_winnings = calculate_winning_numbers(data_file)

    all_card_winnings
    |> Enum.with_index()
    |> Enum.map_reduce(%{}, fn {_numbers, idx}, acc -> calculate_card_scratcher_value(idx, all_card_winnings, acc) end)
    |> elem(0) # just need the numbers, not the cache
    |> Enum.sum()
  end

  def calculate_winning_numbers(data_file) do
    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&extract_game_data(&1))
    |> Enum.map(&find_winning_numbers(&1))
  end

  def extract_game_data(line) do
    [_card_info, winners, numbers] = line
    |> String.split(~r/(:|\s+\|)\s+/, trim: true)

    [winners, numbers]
    |> Enum.map(
      fn list -> list
        |> String.split(~r/\s+/, trim: true)
        |> Enum.map(&String.to_integer(&1))
      end
    )
  end

  def find_winning_numbers([winners, numbers]) do
    numbers
    |> Enum.filter(fn number -> Enum.member?(winners, number) end)
  end

  def calculate_card_point_value(numbers) do
    if Enum.empty?(numbers) do
      0
    else
      2 ** (length(numbers) - 1)
    end
  end

  def calculate_card_scratcher_value(idx, all_card_winnings, cache) do
    if Map.has_key?(cache, idx) do
      # if the value is already in the cache, return it
      {Map.get(cache, idx), cache}
    else
      # otherwise, calculate it recursively
      size = Enum.at(all_card_winnings, idx) |> length()

      {value, cache} = if size == 0 do
        {1, cache}
      else
        other_card_values = for i <- (idx + 1)..(idx + size) do
          calculate_card_scratcher_value(i, all_card_winnings, cache) # recursion!
        end
        {_, cache} = List.first(other_card_values)
        v = other_card_values |> Enum.map(&(&1 |> elem(0))) |> Enum.sum()
        {v + 1, cache}
      end

      {value, Map.put(cache, idx, value)}
    end

  end
end
