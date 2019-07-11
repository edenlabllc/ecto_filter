use Mix.Config

config :git_ops,
  mix_project: EctoFilter.MixProject,
  repository_url: "https://github.com/edenlabllc/ecto_filter",
  manage_mix_version?: true,
  manage_readme_version: true

import_config "#{Mix.env()}.exs"
