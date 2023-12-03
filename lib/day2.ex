defmodule Mix.Tasks.Aoc2023.Day2 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day2.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day2 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day2.part1("data/samples/day2.txt")
      8

  """
  def part1(data_file \\ "data/day2.txt") do
    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&extract_game_data(&1))
    |> Enum.filter(
        fn [_game_id, game_data] ->
          Enum.all?(game_data, fn pull_data ->
            Enum.all?(pull_data, fn {color, count} -> count <= color_limit(color) end)
          end)
        end
      )
    |> Enum.map(&(&1 |> List.first()))
    |> Enum.sum()
  end

  @doc """
  Solve Day2 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day2.part2("data/samples/day2.txt")
      2286

  """
  def part2(data_file \\ "data/day2.txt") do
    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&extract_game_data(&1))
    |> Enum.map(&calculate_max_per_color(&1))
    |> Enum.map(&(&1 |> List.last() |> Map.values() |> Enum.product()))
    |> Enum.sum()
  end

  @doc """
  Returns the color limit for a given color

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day2.color_limit("red")
      12

  """
  def color_limit(color), do: %{"red" => 12, "green" => 13, "blue" => 14} |> Map.get(color)

  @doc """
  Returns the highest value for each color in a given game

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day2.calculate_max_per_color(
      ...>  [1, [[{"blue", 3}, {"red", 4}], [{"red", 1}, {"green", 2}, {"blue", 6}]]]
      ...>)
      [1, %{"blue" => 6, "green" => 2, "red" => 4}]

  """
  def calculate_max_per_color([game_id, game_data]) do
    max_per_color = Enum.reduce(game_data, %{}, fn pulls, acc ->
      Enum.reduce(pulls, acc, fn {color, count}, acc ->
        Map.update(acc, color, count, &(if &1 > count, do: &1, else: count))
      end)
    end)

    [game_id, max_per_color]
  end

  defp extract_game_data(line) do
    [raw_game_id, raw_game_data] = String.split(line, ": ")
    game_id = Regex.run(~r/(\d+)$/, raw_game_id)
    |> List.last()
    |> String.to_integer()


    game_data = String.split(raw_game_data, "; ")
    |> Enum.map(&extract_cube_pulls(&1))

    [game_id, game_data]
  end

  defp extract_cube_pulls(raw_cube_pulls) do
    String.split(raw_cube_pulls, ", ")
    |> Enum.map(&extract_color_pull(&1))
  end

  defp extract_color_pull(raw_color_pull) do
    [count, color] = String.split(raw_color_pull, " ")

    {color, String.to_integer(count)}
  end
end
