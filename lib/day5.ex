defmodule Mix.Tasks.Aoc2023.Day5 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day5.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day5 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day5.part1("data/samples/day5.txt")
      35

  """
  def part1(data_file \\ "data/day5.txt") do
    lines = data_file
    |> File.read!()
    |> String.split("\n", trim: true)

    [first_line | mapping_lines] = lines

    seeds = first_line
    |> extract_seeds()

    mappings = mapping_lines
    |> extract_mappings()
    |> elem(1)

    seeds
    |> Enum.map(&find_location_mapping(&1, "seed", mappings))
    |> List.flatten()
    |> Enum.min()
  end

  @doc """
  Solve Day5 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day5.part2("data/samples/day5.txt")
      46

  """
  def part2(data_file \\ "data/day5.txt") do
    lines = data_file
    |> File.read!()
    |> String.split("\n", trim: true)

    [first_line | mapping_lines] = lines

    seeds = first_line
    |> extract_seeds()
    |> Enum.chunk_every(2)
    |> Enum.map(fn [a, b] -> a..(a + b) end)

    mappings = mapping_lines
    |> extract_mappings()
    |> elem(1)

    find_lowest_location_with_seed(seeds, mappings)
  end

  def extract_seeds(line) do
    line
    |> String.split(~r/:\s+/, trim: true)
    |> List.last()
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def extract_mappings(lines) do
    mapping_regex = ~r/^([a-z]+\-to\-[a-z]+) map:$/
    lines
    |> Enum.reduce(
        {nil, %{}},
        fn line, acc ->
          {current, mappings} = acc
          case Regex.run(mapping_regex, line) do
            [_, from_to] ->
              {from_to, Map.put(mappings, from_to, [])}
            _ ->
              line_contents = line
              |> String.split(~r/\s+/, trim: true)
              |> Enum.map(&String.to_integer(&1))

              line_variance = List.last(line_contents)
              source_range = line_contents
              |> Enum.take(2) |> Enum.take(-1) # better way to get the second element as a list?
              |> Enum.map(&(&1..(&1 + line_variance - 1)))
              |> List.first()

              offset = line_contents|> Enum.take(2) |> Enum.reduce(&(&2 - &1))

              {current, Map.put(mappings, current, [[source_range, offset] | mappings[current]])}
          end
        end
      )
  end

  defp find_location_mapping(value, "location", _mappings) do
    value
  end
  defp find_location_mapping(value, value_type, mappings) when is_integer(value) do
    {to_type, mapping_ranges} = mappings
    |> Enum.find_value(
      fn {from_to, mapping_ranges} ->
        [from_type, to_type] = String.split(from_to, "-to-")
        if from_type == value_type do
          {to_type, mapping_ranges}
        end
      end)

    {_, offset} = calculate_offset(mapping_ranges, value)

    find_location_mapping(value + offset, to_type, mappings)
  end

  defp calculate_offset(mapping_ranges, value) do
    mapping_ranges
    |> Enum.map(fn [map_range, offset] ->
      if Enum.member?(map_range, value) do
        {true, offset}
      else
        {false, offset}
      end
    end)
    |> Enum.filter(fn {viable, _o} -> viable end)
    |> List.first({false, 0})
  end

  defp find_lowest_location_with_seed(seeds, mappings) do
    {_, locations} = mappings
    |> Enum.find(
      fn {from_to, _} -> String.ends_with?(from_to, "location") end
    )

    highest_location = locations
    |> Enum.map(&List.first(&1))
    |> Enum.max()
    |> Enum.max()

    0..highest_location
    |> Stream.chunk_every(100_000)
    |> Enum.find_value(
      fn chunk ->
        Enum.chunk_every(chunk, 2_000)
        |> Task.async_stream(
          fn chunk ->
            Enum.find(chunk, fn location ->
              result = find_seed_mapping(location, "location", seeds, mappings)
              if result, do: {location, result}, else: result
            end)
          end
        )
        |> Enum.map(fn {_, result} -> result end)
        |> Enum.min()
      end
    )
  end

  defp find_seed_mapping(value, "seed", seeds, _mappings) do
    if Enum.any?(seeds, fn seed -> Enum.member?(seed, value) end) do
      true
    else
      false
    end
  end
  defp find_seed_mapping(value, value_type, seeds, mappings) do
    # IO.puts("Finding seed mapping for #{value} of type #{value_type}")
    {from_type, mapping_ranges} = mappings
    |> Enum.find_value(
      fn {from_to, mapping_ranges} ->
        [from_type, to_type] = String.split(from_to, "-to-")
        if to_type == value_type do
          {from_type, mapping_ranges}
        end
      end)

    {_, offset} = calculate_reverse_offset(mapping_ranges, value)

    find_seed_mapping(value - offset, from_type, seeds, mappings)
  end

  defp calculate_reverse_offset(mapping_ranges, value) do
    mapping_ranges
    |> Enum.map(fn [map_range, offset] ->
      if Enum.member?(map_range, value - offset) do
        {true, offset}
      else
        {false, offset}
      end
    end)
    |> Enum.filter(fn {viable, _o} -> viable end)
    |> List.first({false, 0})
  end
end
