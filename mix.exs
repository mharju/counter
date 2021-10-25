defmodule Counter.MixProject do
  use Mix.Project

  def project do
    [
      app: :"Elixir.Counter",
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:cloudi_core, :cloudi_service_db_pgsql]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"}
    ]
  end
end
