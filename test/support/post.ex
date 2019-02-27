defmodule EctoFilter.Post do
  use Ecto.Schema

  alias EctoFilter.{Comment, User}

  schema "posts" do
    field(:title, :string)
    field(:body, :string)
    field(:tags, {:array, :string})

    belongs_to(:author, User)
    has_many(:comments, Comment)
    has_many(:comments_authors, through: [:comments, :author])

    timestamps()
  end
end
