defmodule Mix.Tasks.Aoc2023.Day11 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day11.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    # p2 = part2() |> IO.inspect(label: "Part 2")
    # [p1, p2]
    [p1]
  end

  @doc """
  Solve Day11 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day11.part1("data/samples/day11.txt")
      374

  """
  def part1(data_file \\ "data/day11.txt") do
    raw_data = data_file
    |> File.read!()
    |> String.split("\n", trim: true)

    graph_points = raw_data
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, index},acc -> build_point(acc, index, line) end)
  end

  def part2(data_file \\ "data/day11.txt") do
    raw_data = data_file
    |> File.read!()
    |> String.split("\n", trim: true)
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

  defp build_graph(points) do
    graph = Graph.new(type: :undirected, vertex_identifier: &(&1))
    Graph.add_edges(graph, points_to_edges(points))
  end

  defp points_to_edges(points) do
    # convert a list of points to a list of graph edges
  end
end
