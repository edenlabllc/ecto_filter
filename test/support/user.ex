defmodule EctoFilter.User do
  use Ecto.Schema

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:age, :integer)
    field(:status, :string)

    belongs_to(:organization, EctoFilter.Organization)
    has_many(:posts, EctoFilter.Post)

    timestamps()
  end
end
