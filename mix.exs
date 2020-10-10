defmodule ClusterYASD.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/alisinabh/libcluster_yasd"

  def project do
    [
      app: :libcluster_yasd,
      version: @version,
      elixir: "~> 1.5",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: "YASD Strategy implementation for libcluster.",
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [extra_applications: [:logger]]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Alisina Bahadori"],
      licenses: ["MIT"],
      links: %{GitHub: @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatter_opts: [gfm: true],
      extras: ["README.md"]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 3.2"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.22.6", only: :dev}
    ]
  end
end
