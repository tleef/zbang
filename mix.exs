defmodule Bliss.MixProject do
  use Mix.Project

  @app :bliss
  @version "1.0.0"
  @elixir_version "~> 1.13"
  @source_url "https://github.com/tleef/bliss"

  def project do
    [
      app: @app,
      name: "Bliss",
      version: @version,
      elixir: @elixir_version,
      source_url: @source_url,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer(),
      docs: docs(),
      package: package()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # Tools
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "#{@version}",
      extras: [
        "README.md"
      ]
    ]
  end

  defp package do
    [
      files: [
        "lib",
        ".formatter.exs",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      maintainers: ["Thomas Lee"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end
end
