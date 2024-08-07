defmodule Dredd.MixProject do
  use Mix.Project

  def project do
    [
      app: :dredd,
      description: "Dredd judges your data. Use it to  yalidate arbitrary Elixir data.",
      version: "2.0.2",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:dialyxir, ">= 1.4.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.34.2", only: :dev, runtime: false},
      {:stream_data, "~> 1.1", only: [:dev, :test]},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_check, ">= 0.15.0", only: [:dev, :test], runtime: false},
      {:excoveralls, ">= 0.18.2", only: :test}
    ]
  end

  defp package do
    %{
      maintainers: ["Marcus Autenrieth"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Prakti/dredd"}
    }
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end
end
