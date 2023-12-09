defmodule Mix.Tasks.Aoc2023.Day8 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day8.
  """
  use Mix.Task
  require Math

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day8 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day8.part1("data/samples/day8.p1.txt")
      2

      iex> Mix.Tasks.Aoc2023.Day8.part1("data/samples/day8.p2.txt")
      6

  """
  def part1(data_file \\ "data/day8.txt") do
    {_, _, count} = data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> extract_pattern_and_mapping()
    |> traverse_mapping(0, "AAA", ~r/^ZZZ$/)

    count
  end

  @doc """
  Solve Day8 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day8.part2("data/samples/day8.p3.txt")
      6

  """
  def part2(data_file \\ "data/day8.txt") do
    {pattern, mapping} = data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> extract_pattern_and_mapping()

    sources = mapping
    |> Enum.filter(fn {key, _} -> Regex.match?(~r/A$/, key) end)

    source_set = sources |> Enum.map(fn {key, _} -> {key, pattern, 0} end)

    multi_traverse_mapping(mapping, source_set, ~r/Z$/)
  end


  def extract_pattern_and_mapping(data) do
    [raw_pattern | raw_mapping] = data

    pattern = raw_pattern |> String.split("", trim: true)

    mapping = raw_mapping
    |> Enum.map(fn line ->
      [key, value] = String.split(line, ~r/\s+=\s+/, trim: true)
      [l, r] = value
      |> String.replace(~r/[()]/, "")
      |> String.split(", ")

      {key, {l, r}}
    end)
    |> Enum.into(%{})

    {pattern, mapping}
  end

  def traverse_mapping({pattern, mapping}, count, destination, final_matcher) do
    dest_pattern = List.first(pattern)
    new_pattern = Enum.slide(pattern, 0, -1)

    new_dest = if dest_pattern == "L" do
      Map.get(mapping, destination) |> elem(0)
    else
      Map.get(mapping, destination) |> elem(1)
    end

    if Regex.match?(final_matcher, destination) do
      {destination, pattern, count}
    else
      traverse_mapping({new_pattern, mapping}, count + 1, new_dest, final_matcher)
    end
  end

  def multi_traverse_mapping(mapping, src_set, final_matcher) do
    src_set
    |> Task.async_stream(fn {src, pattern, count} ->
          traverse_mapping({pattern, mapping}, count, src, final_matcher)
        end,
        ordered: false
      )
    |> Enum.map(&(elem(&1, 1)))
    |> Enum.reduce(1, fn {_, _, count}, acc -> Math.lcm(acc, count) end)
  end
end
