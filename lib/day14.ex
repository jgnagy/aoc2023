defmodule Mix.Tasks.Aoc2023.Day14 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day14.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
    [p1]
  end

  @doc """
  Solve Day14 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day14.part1("data/samples/day14.txt")
      136

  """
  def part1(data_file \\ "data/day14.txt") do
    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> Aoc.Toolbox.transpose()
    |> Enum.map(&slide_rocks(&1))
    |> Aoc.Toolbox.transpose()
    |> calculate_score()
  end

  @doc """
  Solve Day14 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day14.part2("data/samples/day14.txt")
      64

  """
  def part2(data_file \\ "data/day14.txt") do
    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "", trim: true))
    |> spin_cycle(1000000000, [])
  end

  @doc """
  Slides rocks from the right to the left of a line,
  stopping when they encounter another slidable rock, a square rock,
  or the end of the line.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day14.slide_rocks([".", ".", "O", "#", ".", "O", "O"])
      ["O", ".", ".", "#", "O", "O",  "."]

      iex> Mix.Tasks.Aoc2023.Day14.slide_rocks([".", ".", ".", "#", ".", ".", "."])
      [".", ".", ".", "#", ".", ".", "."]

  """
  def slide_rocks(line) do
    cond do
      length(line) == 1 ->
        line
      (Enum.uniq(line) |> length()) == 1 ->
        line
      true ->
        {val, idx} = seek_for_slidable_rock(line)
        adjusted_line = if val == "O", do: Aoc.Toolbox.swap_elements(line, 0, idx), else: line
        [first | rest] = adjusted_line

        [first | slide_rocks(rest)]
    end
  end

  @doc """
  Seeks for the first rock in a line.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day14.seek_for_slidable_rock([".", ".", "O", "#", ".", "O", "O"])
      {"O", 2}

      iex> Mix.Tasks.Aoc2023.Day14.seek_for_slidable_rock(["O", "#", ".", "O", "O"])
      {"O", 0}

  """
  def seek_for_slidable_rock(line) do
    elementes_with_indexes = line
    |> Enum.with_index()

    first_element = List.first(elementes_with_indexes)

    if {".", 0} == first_element do
      {element, idx} = elementes_with_indexes
      |> Enum.split_while(fn {rock, _} -> rock == "." end)
      |> elem(1)
      |> List.first()

      if element == "O", do: {element, idx}, else: first_element
    else
      first_element
    end
  end

  @doc """
  Calculates the score for a line.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day14.calculate_line_score({["O", ".", ".", "#", "O", "O", "."], 1})
      3

      iex> Mix.Tasks.Aoc2023.Day14.calculate_line_score({[".", ".", ".", "#", "#", "O", "."], 2})
      2

      iex> Mix.Tasks.Aoc2023.Day14.calculate_line_score({[".", ".", "."], 8})
      0

  """
  def calculate_line_score({line, idx}) do
    Enum.count(line, &(&1 == "O")) * idx
  end

  defp calculate_score(lines) do
    lines
    |> Enum.reverse()
    |> Stream.with_index(1)
    |> Task.async_stream(&calculate_line_score(&1))
    |> Enum.reduce(0, fn {:ok, num}, acc -> num + acc end)
  end

  defp spin_cycle(lines, 0, _hashes), do: lines
  defp spin_cycle(lines, times, hashes) do
    modified_lines = lines
    |> Aoc.Toolbox.transpose()
    |> Stream.map(&slide_rocks(&1)) # North
    |> Aoc.Toolbox.transpose()
    |> Stream.map(&slide_rocks(&1)) # West
    |> Aoc.Toolbox.transpose()
    |> Stream.map(&Enum.reverse(&1))
    |> Stream.map(&slide_rocks(&1)) # South
    |> Stream.map(&Enum.reverse(&1))
    |> Aoc.Toolbox.transpose()
    |> Stream.map(&Enum.reverse(&1))
    |> Stream.map(&slide_rocks(&1)) # East
    |> Enum.map(&Enum.reverse(&1))

    hash = :erlang.phash2(modified_lines)

    existing_index = Enum.find_index(hashes, fn {h, _} -> h == hash end)
    if existing_index do
      cycle_length = existing_index + 1
      cycle_preamble = Enum.slice(hashes, cycle_length..-1) |> length()
      remainder = (times - cycle_preamble) |> rem(cycle_length)
      target_index = cycle_length - remainder - 2

      Enum.at(hashes, target_index)
      |> elem(1)
      |> calculate_score()
    else
      spin_cycle(modified_lines, times - 1, [{hash, modified_lines} | hashes])
    end
  end
end
