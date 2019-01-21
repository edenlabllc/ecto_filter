defmodule EctoFilter.TestMigration do
  @moduledoc false

  use Ecto.Migration

  def change do
    create table(:organizations) do
      add(:name, :string)

      timestamps()
    end

    create table(:users) do
      add(:first_name, :string)
      add(:last_name, :string)
      add(:email, :string)
      add(:age, :integer)
      add(:status, :string)

      add(:interests, :map)
      add(:settings, :map)
      add(:addresses, :map)

      add(:organization_id, references(:organizations))

      timestamps()
    end

    create table(:posts) do
      add(:title, :string)
      add(:body, :string)
      add(:tags, {:array, :string})

      add(:author_id, references(:users))

      timestamps()
    end
  end
end
