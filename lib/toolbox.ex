defmodule Aoc.Toolbox do
  @spec shoelace_formula([{integer(), integer()}]) :: float()
  @doc """
  Determine's the area of a polygon given the coordinates of its vertices

  ## Reference

    https://en.wikipedia.org/wiki/Shoelace_formula

  ## Examples

      iex> Aoc.Toolbox.shoelace_formula([{0, 0}, {1, 0}, {1, 1}, {0, 1}])
      1.0

      iex> Aoc.Toolbox.shoelace_formula([{7, 2}, {4, 4}, {8, 6}, {7, 2}])
      7.0

      iex> Aoc.Toolbox.shoelace_formula([{3, 1}, {4, 3}, {7, 2}, {4, 4}, {8, 6}, {1, 7}, {3, 1}])
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

  @spec transpose(list(list(any()))) :: list()
  @doc """
  Transpose a list of lists.

  ## Examples

      iex> Aoc.Toolbox.transpose([["a", "b"], ["c", "d"]])
      ...> |> Enum.sort()
      [["a", "c"], ["b", "d"]]

      iex> Aoc.Toolbox.transpose([["a", "b", "c"], ["d", "e", "f"]])
      ...> |> Enum.sort()
      [["a", "d"], ["b", "e"], ["c", "f"]]

      iex> Aoc.Toolbox.transpose([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
      ...> |> Enum.sort()
      [[1, 4, 7], [2, 5, 8], [3, 6, 9]]

  """
  def transpose(list) do
    Stream.zip_with(list, &Function.identity/1)
  end

  @doc """
  Swap elements at specific indexes in a list.

  ## Examples

      iex> Aoc.Toolbox.swap_elements(["a", "b", "c"], 0, 2)
      ["c", "b", "a"]

      iex> Aoc.Toolbox.swap_elements([:a, :b, :c, :d], 0, 2)
      [:c, :b, :a, :d]

      iex> Aoc.Toolbox.swap_elements([[1, 2, 3], [4, 5, 6], [7, 8, 9]], 1, 2)
      [[1, 2, 3], [7, 8, 9], [4, 5, 6]]

  """
  def swap_elements(list, index1, index2) do
    value1 = Enum.at(list, index1)
    value2 = Enum.at(list, index2)

    list
    |> List.replace_at(index1, value2)
    |> List.replace_at(index2, value1)
  end
end

defmodule Aoc.Toolbox.SimpleCache do
  @moduledoc """
  A simple ETS-based cache that wraps expensive functions or data.

  Heavily inspired by https://elixirschool.com/en/lessons/storage/ets#example-ets-usage-13
  """

  @spec get_by(module(), atom(), any(), keyword()) :: any()
  @doc """
  Retrieve a cached value or run the given function, caching + returning
  the result.

  ### Examples

      iex> Aoc.Toolbox.SimpleCache.init()
      iex> Aoc.Toolbox.SimpleCache.get_by(Enum, :join, [["a", "b", "c"]])
      "abc"

  """
  def get_by(mod, f, args, opts \\ []) do
    cache = Keyword.get(opts, :cache, :simple_cache)

    case lookup(cache, [mod, f, args]) do
      nil ->
        ttl = Keyword.get(opts, :ttl, :infinity)
        cache_apply(cache, [mod, f, args], ttl)

      result ->
        result
    end
  end

  @doc """
  Retrieves a value from the ETS cache based on its key.
  """
  def get(key, opts \\ []) do
    cache = Keyword.get(opts, :cache, :simple_cache)
    lookup(cache, key)
  end

  @doc """
  Records a value in the ETS cache corresponding to a unique,
  returning the result.

  ### Examples

      iex> Aoc.Toolbox.SimpleCache.init()
      iex> Aoc.Toolbox.SimpleCache.put("abc", "def")
      "def"

      iex> Aoc.Toolbox.SimpleCache.init(:foo_cache)
      iex> Aoc.Toolbox.SimpleCache.put({:foo, [1, 2]}, 2, cache: :foo_cache, ttl: 10)
      2

  """
  def put(key, value, opts \\ []) do
    cache = Keyword.get(opts, :cache, :simple_cache)
    ttl = Keyword.get(opts, :ttl, :infinity)
    cache_put(cache, key, value, ttl)
    get(key, cache: cache)
  end

  @doc """
  Initializes an ETS cache.
  """
  def init(cache \\ :simple_cache) do
    case :ets.whereis(cache) do
      :undefined -> :ets.new(cache, [:set, :public, :named_table])
      _ -> :ok
    end
  end

  defp lookup(cache, key) do
    case :ets.lookup(cache, key) do
      [result | _] -> check_freshness(result)
      [] -> nil
    end
  end

  defp check_freshness({_key, result, expiration}) do
    cond do
      expiration == :infinity -> result
      expiration > :os.system_time(:seconds) -> result
      true -> nil
    end
  end

  defp cache_apply(cache, [mod, f, args], ttl) do
    result = apply(mod, f, args)
    expiration = if ttl == :infinity, do: ttl, else: :os.system_time(:seconds) + ttl
    :ets.insert(cache, {[mod, f, args], result, expiration})
    result
  end

  defp cache_put(cache, key, value, ttl) do
    expiration = if ttl == :infinity, do: ttl, else: :os.system_time(:seconds) + ttl
    :ets.insert(cache, {key, value, expiration})
    value
  end
end
