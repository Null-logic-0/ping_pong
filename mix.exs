defmodule PingPong.MixProject do
  use Mix.Project

  def project do
    [
      app: :ping_pong,
      version: "0.1.0",
      elixir: "~> 1.15",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      name: "PingPong"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {PingPong, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:req, "~> 0.5"},
      {:jason, "~> 1.4"}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: "https://github.com/Null-logic-0/ping_pong",
      extras: ["README.md", "guides/discord.md", "guides/telegram.md", "LICENSE"],
      assets: %{"static" => "static"}
    ]
  end

  defp description() do
    "PingPong is a small Elixir notification library for sending messages through multiple services with one consistent API."
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "pingpong",
      # These are the default files included in the package
      files: ~w(lib guides static .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/Null-logic-0/ping_pong"}
    ]
  end
end
