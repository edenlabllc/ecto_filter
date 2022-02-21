defmodule EctoFilter.MixProject do
  use Mix.Project

  @version "0.3.2"

  def project do
    [
      app: :ecto_filter,
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: "Aims in building database queries using data as filtering conditions.",
      package: package(),
      deps: deps(),
      docs: docs(),
      name: "EctoFilter",
      source_url: "https://github.com/edenlabllc/ecto_filter"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: extra_applications(Mix.env())
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp extra_applications(:test), do: [:logger, :postgrex]
  defp extra_applications(_), do: [:logger]

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/edenlabllc/ecto_filter"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.6"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, "~> 0.15.0 or ~> 0.16.0 or ~> 1.0"},
      {:jason, "~> 1.1", optional: true},
      {:ex_doc, "~> 0.20", only: :dev, runtime: false},
      {:git_ops, "~> 0.6.0", only: :dev}
    ]
  end

  defp docs do
    [
      main: "EctoFilter"
    ]
  end
end
