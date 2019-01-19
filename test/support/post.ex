defmodule EctoFilter.Post do
  use Ecto.Schema

  schema "posts" do
    field(:title, :string)
    field(:body, :string)
    field(:tags, {:array, :string})

    belongs_to(:author, EctoFilter.User)

    timestamps()
  end
end
