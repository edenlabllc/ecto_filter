# Load up the repository, start it, and run migrations
_ = Ecto.Adapters.Postgres.storage_down(EctoFilter.Repo.config())
:ok = Ecto.Adapters.Postgres.storage_up(EctoFilter.Repo.config())
{:ok, _} = EctoFilter.Repo.start_link()
:ok = Ecto.Migrator.up(EctoFilter.Repo, 0, EctoFilter.TestMigration, log: false)

ExUnit.start()
