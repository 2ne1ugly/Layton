defmodule Layton.MixProject do
  use Mix.Project

  def project do
    [
      app: :layton,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Layton.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:grpc, github: "elixir-grpc/grpc", branch: "fix-read-blocked"},
      {:cowlib, "~> 2.8.0", hex: :grpc_cowlib, override: true},
      {:protobuf, "~> 0.7.1"},
      {:google_protos, "~> 0.1"}
    ]
  end
end
