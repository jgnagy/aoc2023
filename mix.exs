defmodule Aoc2023.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc2023,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:combination, "~> 0.0.3"},
      {:libgraph, "~> 0.16"},
      {:math, "~> 0.6.0"},
      {:pathex, "~> 2.0"}
    ]
  end
end
