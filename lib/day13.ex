defmodule Mix.Tasks.Aoc2023.Day13 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day13.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day13 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day13.part1("data/samples/day13.txt")
      405

  """
  def part1(data_file \\ "data/day13.txt") do
    data_file
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(
      fn terrain ->
        lines = String.split(terrain, "\n", trim: true)

        reflection_point = lines
        |> find_reflections()
        |> Enum.map(fn x -> x + 1 end)

        if Enum.any?(reflection_point) do
          100 * List.first(reflection_point)
        else
          lines
          |> Enum.map(&String.split(&1, "", trim: true))
          |> Aoc.Toolbox.transpose()
          |> Enum.map(&(Enum.join(&1)))
          |> find_reflections()
          |> Enum.map(fn x -> x + 1 end)
          |> List.first()
        end
      end
    )
    |> Enum.sum()
  end

  @doc """
  Solve Day13 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day13.part2("data/samples/day13.txt")
      400

  """
  def part2(data_file \\ "data/day13.txt") do
    data_file
    |> File.read!()
    |> String.split("\n\n", trim: true)
    |> Enum.map(
      fn terrain ->
        lines = String.split(terrain, "\n", trim: true)
        max_row = length(lines) - 1
        max_col = length(List.first(lines) |> String.split("", trim: true)) - 1

        original = find_reflections(lines)
        |> List.first()

        vertical_reflection = find_reflection_with_smudge(lines, 0, 0, max_row, max_col, original)

        if vertical_reflection do
          (vertical_reflection + 1) * 100
        else
          lines = lines
          |> Enum.map(&String.split(&1, "", trim: true))
          |> Aoc.Toolbox.transpose()
          |> Enum.map(&(Enum.join(&1)))

          max_row = length(lines) - 1
          max_col = length(List.first(lines) |> String.split("", trim: true)) - 1

          horizontal_original = if original do
            nil
          else
            find_reflections(lines)
            |> List.first()
          end

          find_reflection_with_smudge(lines, 0, 0, max_row, max_col, horizontal_original) + 1
        end
      end
    )
    |> Enum.sum()
  end

  def find_reflections(lines) do
    chunked = lines
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.with_index()
    |> Enum.filter(fn {[a, b], _idx} -> a == b end)

    if Enum.empty?(chunked) do
      [] # means no lines are duplicated
    else
      dup_lines = chunked
      |> Enum.map(fn {chunk, _idx} -> List.first(chunk) end)
      |> Enum.uniq()

      dup_indexes = chunked
      |> Enum.filter(fn {[line, _line], _idx} -> line in dup_lines end)
      |> Enum.map(fn {_chunk, idx} -> idx end)

      dup_indexes
      |> Enum.filter(
        fn dup_index ->
          above = Enum.slice(lines, 0..dup_index)
          below = Enum.slice(lines, (dup_index + 1)..-1)
          |> Enum.reverse()

          above_length = length(above)
          below_length = length(below)

          cond do
            above_length == below_length ->
              if above -- below == [] do
                true
              else
                nil
              end
            above_length > below_length ->
              excess_row_count = above_length - below_length
              if Enum.slice(above, (excess_row_count..-1)) == below do
                true
              else
                nil
              end
            above_length < below_length ->
              excess_row_count = below_length - above_length
              if Enum.slice(below, (excess_row_count..-1)) == above do
                true
              else
                nil
              end
          end
        end)
    end
  end

  @doc """
  Attempt a reflection after "smudging" a character.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day13.find_reflection_with_smudge(["###", ".#.", "..."], 0, 0, 2, 2)
      1

  """
  def find_reflection_with_smudge(lines, row, column, max_row, max_col, skip \\ nil, acc \\ []) do
    cond do
      row > max_row ->
        acc
        |> Enum.min(fn -> nil end)
      column > max_col ->
        find_reflection_with_smudge(lines, row + 1, 0, max_row, max_col, skip, acc)
      true ->
        result = smudge(lines, row, column)
        |> find_reflections()
        |> Enum.reject(fn x -> x == skip || x == nil end)

        acc = acc ++ result

        find_reflection_with_smudge(lines, row, column + 1, max_row, max_col, skip, acc)
    end
  end

  @doc """
  Smudge a single character in a line.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day13.smudge(["..#", ".#.", "..."], 0, 0)
      ["#.#", ".#.", "..."]

      iex> Mix.Tasks.Aoc2023.Day13.smudge(["..#", ".#.", "..."], 2, 2)
      ["..#", ".#.", "..#"]

  """
  def smudge(lines, row, column) do
    line = Enum.at(lines, row)
    |> String.split("", trim: true)

    char = Enum.at(line, column)

    result = if char == "." do
        List.replace_at(line, column, "#")
    else
        List.replace_at(line, column, ".")
    end
    |> Enum.join("")

    List.replace_at(lines, row, result)
  end
end
