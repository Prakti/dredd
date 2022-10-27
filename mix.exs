defmodule Dredd.MixProject do
  use Mix.Project

  def project do
    [
      app: :dredd,
      description: "Dredd judges your structs. Validate data with Elixir",
      version: "1.0.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
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
      {:dialyxir, "~> 1.2.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:stream_data, "~> 0.5.0", only: [:dev, :test]},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    %{
      maintainers: ["Marcus Autenrieth"],
      licenses: ["MIT"],
      links: %{ "GitHub" => "https://github.com/Prakti/dredd" }
    }
  end
end
