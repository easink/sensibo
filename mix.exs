defmodule Sensibo.MixProject do
  use Mix.Project

  def project do
    [
      app: :sensibo,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        sensibo: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent],
          # steps: [:assemble, :tar]
          steps: [:assemble]
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Sensibo.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:instream, "~> 2.0"},
      {:extrace, "~> 0.6"}
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
