defmodule Mix.Tasks.Aoc2023.Day12 do
  @moduledoc """
  Documentation for Advent of Code 2023 Day12.
  """
  use Mix.Task

  def run(_) do
    p1 = part1() |> IO.inspect(label: "Part 1")
    p2 = part2() |> IO.inspect(label: "Part 2")
    [p1, p2]
  end

  @doc """
  Solve Day12 part 1 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day12.part1("data/samples/day12.txt")
      21

  """
  def part1(data_file \\ "data/day12.txt") do
    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Task.async_stream(
      fn {line, idx} ->
        cache_name = :"part1_#{idx}"
        Aoc.Toolbox.SimpleCache.init(cache_name)

        parse_line(line)
        |> find_solutions(cache_name)
      end,
      ordered: false, timeout: :infinity
    )
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  @doc """
  Solve Day12 part 2 stuff.

  ## Examples

      iex> Mix.Tasks.Aoc2023.Day12.part2("data/samples/day12.txt")
      525152

  """
  def part2(data_file \\ "data/day12.txt") do
    Aoc.Toolbox.SimpleCache.init(:part2)

    data_file
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Task.async_stream(
      fn {line, idx} ->
        cache_name = :"part2_#{idx}"
        Aoc.Toolbox.SimpleCache.init(cache_name)

        parse_line(line)
        |> multiply_line()
        |> find_solutions(cache_name)
      end,
      ordered: false, timeout: :infinity
    )
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def parse_line(line) do
    [data, meta] = line
    |> String.split(" ", trim: true)

    meta = meta
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer(&1))

    data = data
    |> String.replace(~r/\.{2,}/, ".") # dedup dots
    |> String.split("", trim: true)
    |> chunk_input_line()

    {data, meta}
  end

  def chunk_input_line(data) do
    data
    |> Enum.chunk_by(&(&1))
    |> Enum.map(fn c -> if Enum.any?(c, &(&1 == "?")), do: c, else: Enum.join(c, "") end)
    |> List.flatten()
  end

  def multiply_line({data, meta}) do
    data = List.duplicate(data, 5)
    |> Enum.join("?")
    |> String.split("", trim: true)
    |> chunk_input_line()

    meta = List.duplicate(meta, 5)
    |> List.flatten()

    {data, meta}
  end

  @doc """
  Find possible solutions for a line with missing data given its meta data

  ## Examples

      iex> Aoc.Toolbox.SimpleCache.init(:test)
      iex> Mix.Tasks.Aoc2023.Day12.find_solutions({["?", "?", "?", ".", "###"], [1, 1, 3]}, :test)
      1

      iex> Aoc.Toolbox.SimpleCache.init(:test)
      iex> chunks = ["?", "###", "?", "?", "?", "?", "?", "?", "?", "?"]
      iex> Mix.Tasks.Aoc2023.Day12.find_solutions({chunks, [3, 2, 1]}, :test)
      10

  """
  def find_solutions(line_tuple, cache_name, acc \\ 1, mid_chunk? \\ false)
  def find_solutions({[], []}, _cache_name, _acc, _mid_chunk?), do: 1
  def find_solutions({[], _meta}, _cache_name, _acc, _mid_chunk?), do: 0
  def find_solutions({data, []}, _cache_name, _acc, _mid_chunk?) do
    if Enum.any?(data, &String.contains?(&1, "#")), do: 0, else: 1
  end
  def find_solutions({data, meta}, cache_name, acc, mid_chunk?) do
    [d_head | d_tail] = data

    case cache_get(cache_name, {data, meta}) do
      # if we've got a cache miss, do the work and cache the result
      nil ->
        cond do
          # bail early and cache if we know it's impossible
          length(data) < length(meta) -> cache_put(cache_name, {data, meta}, 0)

          String.contains?(d_head, "#") ->
            cache_put(cache_name, {data, meta}, handle_broken_chunk(data, meta, acc, cache_name))

          # if we've encountered a dot, we either bail if mid-chunk (because it won't work)
          # or continue checking for the next chunk of broken springs
          d_head == "." && mid_chunk? -> cache_put(cache_name, {data, meta}, 0)
          d_head == "." ->
            next_result = find_solutions({d_tail, meta}, cache_name, acc)
            cache_put(cache_name, {data, meta}, acc * next_result)

          # at this point, we're dealing with a "?" chunk, so we calculate the solutions
          # for both the case where we fill it in and the case where we skip it
          d_head == "?" ->
            remaining_possibilities = handle_missing_chunk(data, meta, acc, cache_name, mid_chunk?)
            cache_put(cache_name, {data, meta}, acc * remaining_possibilities)
        end

      # if we've got a cache hit, just return the result
      result -> result
    end
  end

  # for caching, we need a cache per line because possibilities are different per input line
  defp cache_get(cache, key), do: Aoc.Toolbox.SimpleCache.get(key, cache: cache)
  defp cache_put(cache, {data, meta}, total) do
    Aoc.Toolbox.SimpleCache.put({data, meta}, total, cache: cache)
  end

  defp handle_broken_chunk(data, meta, acc, cache_name) do
    [d_head | d_tail] = data
    [m_head | m_tail] = meta
    dh_length = String.length(d_head)

    # if we've found a chunk of broken springs, we need to compare its size to the
    # meta data to determine if we should bail, continue, or if we've found a match
    cond do
      m_head < dh_length -> 0
      m_head > dh_length && length(d_tail) > 0 ->
        acc * find_solutions({d_tail, [m_head - dh_length | m_tail]}, cache_name, acc, true)
      m_head > dh_length -> 0
      true ->
        if length(d_tail) > 0 do
          acc * find_solutions({tl(d_tail), m_tail}, cache_name, acc)
        else
          acc
        end
    end
  end

  defp handle_missing_chunk(data, meta, acc, cache_name, mid_chunk?) do
    [_ | d_tail] = data
    [m_head | m_tail] = meta

    # count up the possibilities if this chunk is a "#"
    count_if_broken =
      if length(d_tail) > 0 do
        next_chunk = List.first(d_tail)

        cond do
          # if the next chunk is a dot but we need more than one #, bail
          next_chunk == "." && m_head > 1 -> 0

          # if the next chunk also has a # but we only need one, bail
          String.contains?(next_chunk, "#") && m_head == 1 -> 0

          # if the next chunk is also missing but we only need one #,
          # we have skip (basically this becomes a dot)
          next_chunk == "?" && m_head == 1 ->
            find_solutions({tl(d_tail), m_tail}, cache_name, acc, false)

          # given what we've already looked for, we can skip this if there
          # is more data to process
          m_head == 1 && length(d_tail) > 0 ->
            find_solutions({tl(d_tail), m_tail}, cache_name, acc, false)
          # in this case, we've hit the end of our data so return the accumulator
          m_head == 1 -> acc

          # if we're here, keep processing the chunk we're on because
          # we need more than one # and we've got more data to process
          true ->
            find_solutions({d_tail, [m_head - 1 | m_tail]}, cache_name, acc, true)
        end
      else
        # We've hit the end of the data, so we can only skip if we need one more
        # or say we've hit the only possibility
        if m_head == 1, do: 1, else: 0
      end

    # count up the possibilities if this chunk is a "."
    count_if_working =
      if mid_chunk? do
        0 # can't be a dot if we're in the middle of a chunk of broken springs
      else
        find_solutions({d_tail, meta}, cache_name, acc, mid_chunk?)
      end

    count_if_broken + count_if_working
  end
end
