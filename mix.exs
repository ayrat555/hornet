defmodule Hornet.MixProject do
  use Mix.Project

  def project do
    [
      app: :hornet,
      version: "0.1.2",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "Hornet",
      description: description()
    ]
  end

  defp description do
    """
    Hornet is a simple library for stress testing.
    """
  end

  defp package do
    [
      name: :hornet,
      maintainers: ["Ayrat Badykov"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ayrat555/hornet"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.5.0-rc.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
