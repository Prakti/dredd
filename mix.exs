defmodule Dredd.MixProject do
  use Mix.Project

  def project do
    [
      app: :dredd,
      description: "Dredd judges your structs. Validate data with Elixir",
      version: "1.0.0",
      elixir: "~> 1.9",
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
      {:dialyxir, "~> 1.1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:stream_data, "~> 0.4.3", only: [:dev, :test]}
    ]
  end

  defp package do
    %{
      maintainers: ["Marcus Autenrieth"],
      licenses: ["MIT"],
      links: %{}
    }
  end
end
