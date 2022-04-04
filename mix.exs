defmodule ExFactor.MixProject do
  use Mix.Project

  @source_url "https://github.com/jeremylightsmith/ex_factor"
  @version "0.1.0"

  def project do
    [
      app: :ex_factor,
      description: "Refactoring for Elixir",
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: docs(),
      escript: [main_module: ExFactor.CLI],
      package: [
        maintainers: ["Jeremy Lightsmith"],
        licenses: ["MIT"],
        links: %{
          "Changelog" => "https://hexdocs.pm/ex_factor/changelog.html",
          "GitHub" => @source_url
        },
        files: ~w(LICENSE README.md CHANGELOG.md lib mix.exs)
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:sourceror, "~> 0.11"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp docs do
    [
      extras: ["CHANGELOG.md", "README.md"],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end
end
