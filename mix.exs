defmodule HoloceneCalendar.MixProject do
  use Mix.Project

  def project do
    [
      app: :holocene_calendar,
      name: "Holocene Calendar",
      source_url: "https://github.com/andreasknoepfle/holocene_calendar",
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A holocene calendar implementation.",
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{github: "https://github.com/andreasknoepfle/holocene_calendar"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
