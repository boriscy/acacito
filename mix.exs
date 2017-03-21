defmodule Publit.Mixfile do
  use Mix.Project

  def project do
    [app: :publit,
     version: "0.9.#{committed_at()}",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     description: "Main API and app to control the orders and tracking the transport",
     #docs: [main: "README"],
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Publit, []},
     applications: [
      :phoenix,
      :phoenix_pubsub,
      :phoenix_html,
      :cowboy,
      :cors_plug,
      :logger,
      :gettext,
      :phoenix_ecto,
      :postgrex,
      :comeonin,
      :arc,
      :arc_ecto,
      :httpoison,
      :ex_aws,
      :hackney,
      :poison]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.1"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.2.1"},
     {:ecto, "~>2.1.1", override: true},
     {:ex_doc, "~> 0.15", only: :dev, runtime: false},
     {:postgrex, "~> 0.13", override: true},
     {:phoenix_html, "~> 2.9"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.13"},
     {:cowboy, "~> 1.1"},
     {:comeonin, "~> 3.0"},
     {:geo, "~> 1.4"},
     {:poison, "~> 3.1", override: true},
     {:ex_aws, "~> 1.1", override: true},
     {:arc, "~> 0.7.0"},
     {:arc_ecto, "0.6.0"},
     {:cors_plug, "~> 1.2"},
     {:earmark, "~> 1.0"},
     {:httpoison, "0.11.0"},
     {:hackney, "1.6.5"},
     {:sweet_xml, "~> 0.6"},
     {:ex_machina, "~> 2.0", only: [:dev, :test]},
     {:mock, "~> 0.2.0", only: :test},
     {:distillery, "~> 1.0"}]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end

  @doc "Unix timestamp of the last commit."
  def committed_at do
    System.cmd("git", ~w[log -1 --date=short --pretty=format:%ct]) |> elem(0)
  end
end
