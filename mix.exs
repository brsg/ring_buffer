defmodule RingBuffer.MixProject do
  use Mix.Project

  def project do
    [
      app: :ring_buffer,
      version: "0.1.0",
      elixir: "~> 1.11",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "RingBuffer",
      source_url: "https://github.com/brsg/ring_buffer"
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1"},
      {:ex_doc, "~> 0.11", only: :dev},
      {:earmark, "~> 0.1", only: :dev}
    ]
  end

  defp description do
    """
    `RingBuffer` is an implementation of a ring or circular buffer data
     structure, internally based on Erlang's :queue, that offers a few
     niceties such as access to the buffer item that is evicted when a
     new item is added to a full buffer.
    """
  end
  
  defp package do
    [
      name: "ring_buffer",
      organization: "brsg",
      maintainers: ["Dave Muirhhead", "Alan Strait"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/brsg/ring_buffer",
              "Docs" => "http://hexdocs.pm/ring_buffer/"}
     ]
  end

end
