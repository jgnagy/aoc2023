defmodule Mix.Tasks.Aoc2023.Day10 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day10.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day10 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day10.part1("data/samples/day10.p1.txt")
      4

      iex> Mix.Tasks.Aoc2023.Day10.part1("data/samples/day10.p2.txt")
      8

  """
  def part1(data_file \\ "data/day10.txt") do
    raw_data = data_file
    |> File.read!()
    |> String.split("\n", trim: true)

    graph = raw_data
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, index},acc -> add_to_graph(acc, index, line) end)

    start = graph
    |> find_start()

    calculate_loop(graph, start, [])
    |> Enum.count()
    |> div(2)
  end

  @doc """
  Solve Day10 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day10.part2("data/samples/day10.p3.txt")
      4

      iex> Mix.Tasks.Aoc2023.Day10.part2("data/samples/day10.p3_5.txt")
      4

      iex> Mix.Tasks.Aoc2023.Day10.part2("data/samples/day10.p4.txt")
      8

      iex> Mix.Tasks.Aoc2023.Day10.part2("data/samples/day10.p5.txt")
      10

  """
  def part2(data_file \\ "data/day10.txt") do
    raw_data = data_file
    |> File.read!()
    |> String.split("\n", trim: true)

    graph = raw_data
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, index},acc -> add_to_graph(acc, index, line) end)

    start = graph
    |> find_start()

    loop = calculate_loop(graph, start, [])

    shoelace_formula(loop)
    |> find_interior_via_picks_theorem(Enum.count(loop))
    |> round()
  end

  def add_to_graph(graph, index, line) do
    y = index * -1

    line
    |> String.split("", trim: true)
    |> Enum.with_index()
    |> Enum.reduce(graph, fn {char, x}, acc ->
      Map.put(acc, {x, y}, %{symbol: char, connections: connections_for(char, x, y)})
    end)
  end

  @doc """
  Find the connections for a given point based on the symbol at that point.

  ## Examples

    iex> Mix.Tasks.Aoc2023.Day10.connections_for(".", 0, 0)
    []

    iex> Mix.Tasks.Aoc2023.Day10.connections_for("|", 0, 0)
    [{0, -1}, {0, 1}]
  """
  def connections_for(char, x, y) do
    case char do
      "." -> []
      "|" -> [{x, y - 1}, {x, y + 1}]
      "-" -> [{x - 1, y}, {x + 1, y}]
      "L" -> [{x, y + 1}, {x + 1, y}]
      "J" -> [{x, y + 1}, {x - 1, y}]
      "7" -> [{x, y - 1}, {x - 1, y}]
      "F" -> [{x, y - 1}, {x + 1, y}]
      "S" -> []
    end
  end

  @doc """
  Find the start of the loop in the graph.

  ## Examples

    iex> Mix.Tasks.Aoc2023.Day10.find_start(%{{0, 0} => %{symbol: ".", connections: []}, {1, 0} => %{connections: [], symbol: "S"}})
    {1, 0}
  """
  def find_start(graph) do
    graph
    |> Enum.find(fn {_coordinates, data} -> data.symbol == "S" end)
    |> elem(0)
  end

  def calculate_loop(graph, start_coordinates, []) do
    # First, we need to find a point that has a connection to the start
    bootstrap_point = calculate_adjacent_points(start_coordinates)
    |> Enum.filter(fn {x, y} -> Map.has_key?(graph, {x, y}) end)
    |> Enum.find(fn {x, y} -> Enum.member?(graph[{x, y}].connections, start_coordinates) end)

    # Now we complete the loop, starting at the bootstrap point and ending at the start
    calculate_loop(graph, bootstrap_point, [start_coordinates, bootstrap_point])
  end
  def calculate_loop(graph, point, loop_points) do
    start_point = Enum.at(loop_points, 0)
    prev_point = Enum.at(loop_points, -2)
    next_point = graph[point].connections -- [prev_point]
    |> List.first()

    if next_point == start_point do
      loop_points
    else
      calculate_loop(graph, next_point, loop_points ++ [next_point])
    end
  end

  @doc """
  Determine's the area of a polygon given the coordinates of its vertices

  ## Reference

    https://en.wikipedia.org/wiki/Shoelace_formula

  ## Examples

    iex> Mix.Tasks.Aoc2023.Day10.shoelace_formula([{0, 0}, {1, 0}, {1, 1}, {0, 1}])
    1.0

    iex> Mix.Tasks.Aoc2023.Day10.shoelace_formula([{7, 2}, {4, 4}, {8, 6}, {7, 2}])
    7.0

    iex> Mix.Tasks.Aoc2023.Day10.shoelace_formula([{3, 1}, {4, 3}, {7, 2}, {4, 4}, {8, 6}, {1, 7}, {3, 1}])
    17.0
  """
  def shoelace_formula(path) do
    # convert the path to a list of rows and columns (x values and y values)
    [[x1 | xn] = rows, [y1 | yn] = columns] = path
    |> Enum.reduce([[], []], fn {r, c}, [rows, columns] -> [[r | rows], [c | columns]] end)

    color1 = Enum.zip(rows, yn ++ [y1]) |> Enum.reduce(0, fn {r, c}, sum -> sum + r * c end)

    color2 = Enum.zip(columns, xn ++ [x1]) |> Enum.reduce(0, fn {c, r}, sum -> sum + c * r end)
    (abs(color1 - color2) / 2)
  end

  @doc """
  Given the area of a polygon and the number of points on its boundary,
  find the number of points in its interior.

  ## Reference

    https://en.wikipedia.org/wiki/Pick%27s_theorem

  ## Examples

    iex> Mix.Tasks.Aoc2023.Day10.find_interior_via_picks_theorem(10.0, 8)
    7.0

    iex> Mix.Tasks.Aoc2023.Day10.find_interior_via_picks_theorem(8.0, 12)
    3.0

    iex> Mix.Tasks.Aoc2023.Day10.find_interior_via_picks_theorem(48.0, 96)
    1.0
  """
  def find_interior_via_picks_theorem(area, boundary_points) do
    area - boundary_points / 2 + 1
  end

  defp calculate_adjacent_points({x, y}) do
    [
      {x, y - 1},
      {x, y + 1},
      {x - 1, y},
      {x + 1, y},
      {x - 1, y - 1},
      {x + 1, y + 1},
      {x - 1, y + 1},
      {x + 1, y - 1}
    ]
  end
end
