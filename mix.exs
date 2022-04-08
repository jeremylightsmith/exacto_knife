defmodule ExactoKnife.MixProject do
  use Mix.Project

  @source_url "https://github.com/jeremylightsmith/exacto_knife"
  @version "0.1.3"

  def project do
    [
      app: :exacto_knife,
      description: "Refactoring for Elixir",
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: docs(),
      escript: [main_module: ExactoKnife.CLI],
      package: [
        maintainers: ["Jeremy Lightsmith"],
        licenses: ["MIT"],
        links: %{
          "Changelog" => "https://hexdocs.pm/exacto_knife/changelog.html",
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
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:sourceror, "~> 0.11"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false}
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
