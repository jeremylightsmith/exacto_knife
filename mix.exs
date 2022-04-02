defmodule ExactoKnife.MixProject do
  use Mix.Project

  def project do
    [
      app: :exacto_knife,
      version: "0.1.0",
      elixir: "~> 1.13",
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

  defp deps do
    [
      {:sourceror, "~> 0.10"}
    ]
  end
end
