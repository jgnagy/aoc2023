defmodule Mix.Tasks.Aoc2023.Day7 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day7.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day7 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day7.part1("data/samples/day7.txt")
      6440

  """
  def part1(data_file \\ "data/day7.txt") do
    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&extract_hand_and_bet(&1))
    |> Enum.sort_by(fn {_, sort_key, _} -> sort_key end)
    |> calculate_hand_scores()
    |> Enum.sum()
  end

  @doc """
  Solve Day7 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day7.part2("data/samples/day7.txt")
      5905

  """
  def part2(data_file \\ "data/day7.txt") do
    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&extract_hand_and_bet(&1, true))
    |> Enum.sort_by(fn {_, sort_key, _} -> sort_key end)
    |> calculate_hand_scores()
    |> Enum.sum()
  end

  @doc """
  Extract the hand, hand sort key, and bet from an input line.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day7.extract_hand_and_bet("32J3K 765")
      {"32J3K", [1, 3, 2, 11, 3, 13], 765}

      iex> Mix.Tasks.Aoc2023.Day7.extract_hand_and_bet("32J3K 888", true)
      {"32J3K", [3, 3, 2, 1, 3, 13], 888}

      iex> Mix.Tasks.Aoc2023.Day7.extract_hand_and_bet("32T3K 987", true)
      {"32T3K", [1, 3, 2, 10, 3, 13], 987}

      iex> Mix.Tasks.Aoc2023.Day7.extract_hand_and_bet("JJJJJ 222", true)
      {"JJJJJ", [6, 1, 1, 1, 1, 1], 222}
  """
  def extract_hand_and_bet(line, wilds \\ false) do
    raw_hand = line
    |> String.split(~r/\s+/, trim: true)
    |> List.first()

    hand = raw_hand
    |> String.split("", trim: true)
    |> Enum.map(&convert_to_number(&1, wilds))

    hand_value = calculate_hand_value(hand)

    bet = line
    |> String.split(~r/\s+/, trim: true)
    |> List.last()
    |> String.to_integer()

    # actual_hand, sort_key, bet
    {raw_hand, List.flatten([hand_value, hand]), bet}
  end

  # If we have 5 wilds, we have a "5 of a kind" so we can just return the hand
  defp account_for_wilds(%{1 => 5} = grouped_hand), do: grouped_hand
  # Otherwise, we need to add the wilds to the highest grouping
  defp account_for_wilds(grouped_hand) do
    wilds = grouped_hand[1] || 0

    {k, _} = grouped_hand
    |> Map.filter(fn {key, _} -> key != 1 end)
    |> Enum.sort_by(fn {_, value} -> value end)
    |> List.last() || {1, 0}

    Map.update!(grouped_hand, k, &(&1 + wilds))
    |> Map.delete(1)
  end

  defp calculate_hand_value(hand) do
    hand
    |> Enum.reduce(%{}, fn card, acc ->
      Map.update(acc, card, 1, &(&1 + 1))
    end)
    |> account_for_wilds()
    |> Map.values()
    |> Enum.sort()
    |> convert_hand_assessment()
  end

  defp convert_to_number(number, wilds) do
    case number do
      "A" -> 14
      "K" -> 13
      "Q" -> 12
      "J" -> if wilds, do: 1, else: 11
      "T" -> 10
      _ -> number |> String.to_integer()
    end
  end

  defp calculate_hand_scores(hands) do
    hands
    |> Enum.with_index(1)
    |> Enum.map(fn {{_, _, bet}, index} -> bet * index end)
  end

  defp convert_hand_assessment(hand_assessment) do
    [[1, 1, 1, 1, 1], [1, 1, 1, 2], [1, 2, 2], [1, 1, 3], [2, 3], [1, 4], [5]]
    |> Enum.find_index(&(&1 == hand_assessment))
  end
end
