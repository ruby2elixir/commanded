defmodule Commanded.Mixfile do
  use Mix.Project

  def project do
    [
      app: :commanded,
      version: "0.1.0",
      elixir: "~> 1.3",
      elixirc_paths: elixirc_paths(Mix.env),
      description: description,
      package: package,
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      consolidate_protocols: Mix.env == :prod,
      deps: deps
    ]
  end

  def application do
    [
      applications: [
        :logger,
        :eventstore
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/example_domain", "test/helpers"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:eventstore, github: "slashdotdash/eventstore"},
      {:eventsourced, github: "slashdotdash/eventsourced"},
      {:ex_doc, "~> 0.13.0", only: :dev},
      {:markdown, github: "devinus/markdown", only: :dev},
      {:mix_test_watch, "~> 0.2", only: :dev},
      {:poison, "~> 2.2.0"}
    ]
  end

  defp description do
"""
Command handling middleware for CQRS applications
"""
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Ben Smith"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/slashdotdash/commanded",
               "Docs" => "https://hexdocs.pm/commanded/"}
    ]
  end
end
