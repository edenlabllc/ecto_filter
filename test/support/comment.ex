defmodule EctoFilter.Comment do
  use Ecto.Schema

  alias EctoFilter.{Post, User}

  schema "comments" do
    field(:body, :string)

    belongs_to(:author, User)
    belongs_to(:post, Post)

    timestamps()
  end
end
