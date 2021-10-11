defmodule EctoMySQLExtras.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/timothyvanderaerden/ecto_mysql_extras"

  def project do
    [
      app: :ecto_mysql_extras,
      version: @version,
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      name: "Ecto MySQL Extras",
      description: "Ecto MySQL (and MariaDB) database performance insights.",
      source_url: @source_url,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: preferred_cli_env(),
      dialyzer: dialyzer(),
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  defp preferred_cli_env() do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      "coveralls.json": :test
    ]
  end

  defp dialyzer() do
    [
      plt_add_apps: [
        :table_rex,
        :phoenix,
        :phoenix_live_view,
        :phoenix_live_dashboard
      ]
    ]
  end

  defp package() do
    [
      maintainers: ["Timothy Vanderaerden"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp docs() do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: ["README.md"]
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.7"},
      {:myxql, "~> 0.5"},

      # Optional
      {:table_rex, "~> 3.1", optional: true},

      # Development
      {:credo, "~> 1.5", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
