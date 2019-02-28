use Mix.Config

config :ecto_filter, ecto_repos: [EctoFilter.Repo]

config :ecto_filter, EctoFilter.Repo,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: "postgres",
  database: "ecto_filter_test"

config :logger, :console, level: :warn
