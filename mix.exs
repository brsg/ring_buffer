defmodule RingBuffer.MixProject do
  use Mix.Project

  @source_url "https://github.com/brsg/ring_buffer"
  @version "0.1.0"

  def project do
    [
      app: :ring_buffer,
      version: @version,
      elixir: "~> 1.11",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      source_url: @source_url
    ]
  end

  def application do
    [
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.11", only: :dev, runtime: false},
      {:earmark, "~> 0.1", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A ring or circular buffer data structure with extras.
    """
  end
  
  defp package do
    [
      maintainers: ["Dave Muirhhead", "Alan Strait"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

end
